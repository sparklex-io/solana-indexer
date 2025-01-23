use anyhow::{anyhow, Error, Context};

use substreams_database_change::pb::database::DatabaseChanges;
use substreams_database_change::tables::{Row, Tables};
use substreams_solana::pb::sf::solana::r#type::v1::{Block, ConfirmedTransaction};

use substreams_solana_utils::transaction::{get_context, get_signature, get_signers, TransactionContext};

use raydium_amm_substream;
use raydium_amm_substream::raydium_amm::constants::RAYDIUM_AMM_PROGRAM_ID;
use raydium_amm_substream::raydium_clmm::constants::RAYDIUM_CLAMM_PROGRAM_ID;
use raydium_amm_substream::pb::raydium_amm::raydium_amm_event;

use pumpfun_substream;
use pumpfun_substream::pumpfun::PUMPFUN_PROGRAM_ID;
use pumpfun_substream::pb::pumpfun::pumpfun_event;

mod instruction;
use instruction::{get_indexed_instructions, IndexedInstruction, IndexedInstructions};

#[substreams::handlers::map]
fn block_database_changes(block: Block) -> Result<DatabaseChanges, Error> {
    let mut tables = Tables::new();
    for (index, transaction) in block.transactions.iter().enumerate() {
        match parse_transaction(transaction, index as u32, block.slot, &block.blockhash, &mut tables)? {
            true => {
                let signers = get_signers(transaction);
                let row = tables.create_row("transactions", [("slot", block.slot.to_string()), ("transaction_index", index.to_string())])
                    .set("signature", get_signature(transaction))
                    .set("number_of_signers", signers.len().to_string());
                for i in 0..8 {
                    row.set(&format!("signer{i}"), signers.get(i).unwrap_or(&"".into()));
                }
            },
            false => (),
        }
    }
    tables.create_row("blocks", block.slot.to_string())
        .set("parent_slot", block.parent_slot)
        .set("block_height", block.block_height.as_ref().unwrap().block_height)
        .set("blockhash", block.blockhash)
        .set("previous_blockhash", block.previous_blockhash)
        .set("block_time", block.block_time.as_ref().unwrap().timestamp);
   Ok(tables.to_database_changes())
}

fn parse_transaction<'a>(
    transaction: &ConfirmedTransaction,
    transaction_index: u32,
    slot: u64,
    blockhash: &String,
    tables: &mut Tables,
) -> Result<bool, Error> {
    if let Some(_) = transaction.meta.as_ref().unwrap().err {
        return Ok(false);
    }

    let instructions = get_indexed_instructions(transaction)?;
    let mut context = get_context(transaction)?;

    let mut tables_changed = false;
    for instruction in instructions.flattened().iter() {
        context.update_balance(&instruction.instruction.instruction);
        match parse_instruction(instruction, &context, tables, slot, transaction_index).with_context(|| format!("Transaction {}", context.signature))? {
            Some(row) => {
                row
                    .set("partial_signature", &context.signature[0..4])
                    .set("partial_blockhash", &blockhash[0..4]);
                tables_changed = true;
            },
            None => (),
        }
    }

    Ok(tables_changed)
}

fn parse_instruction<'a>(
    instruction: &IndexedInstruction,
    context: &TransactionContext,
    tables: &'a mut Tables,
    slot: u64,
    transaction_index: u32,
) -> Result<Option<&'a mut Row>, Error> {
    let program_id = instruction.program_id();
    let row = if program_id == RAYDIUM_AMM_PROGRAM_ID {
        parse_raydium_amm_instruction(instruction, context, tables, slot, transaction_index)
    } else if program_id == PUMPFUN_PROGRAM_ID {
        parse_pumpfun_instruction(instruction, context, tables, slot, transaction_index)
    } else if program_id == RAYDIUM_CLAMM_PROGRAM_ID {
        parse_raydium_clmm_instruction(instruction, context, tables, slot, transaction_index)
    } else {
        return Ok(None);
    }?;

    if let Some((row, skip_custom_fields)) = row {
        if !skip_custom_fields {
            if let Some(parent_instruction) = instruction.parent_instruction() {
            let top_instruction = instruction.top_instruction().unwrap();
            row
                .set("parent_instruction_program_id", parent_instruction.program_id().to_string())
                .set("parent_instruction_index", parent_instruction.index)
                .set("top_instruction_program_id", top_instruction.program_id().to_string())
                .set("top_instruction_index", top_instruction.index);
        } else {
                row
                    .set("parent_instruction_program_id", "")
                    .set("parent_instruction_index", -1)
                    .set("top_instruction_program_id", "")
                    .set("top_instruction_index", -1);
            }
        }
        Ok(Some(row))
    } else {
        Ok(None)
    }
}

fn parse_raydium_clmm_instruction<'a>(
    instruction: &IndexedInstruction,
    context: &TransactionContext,
    tables: &'a mut Tables,
    slot: u64,
    transaction_index: u32,
) -> Result<Option<(&'a mut Row, bool)>, Error> {
    let row = match raydium_amm_substream::cl_parser::parse_cl_instruction(&instruction.instruction, context).map_err(Error::msg)? {
        Some(raydium_amm_event::Event::ClCreatePool(create_pool)) => {
            let sqrt_price = u128::from_le_bytes(create_pool.sqrt_price.try_into().map_err(|_| anyhow!("Failed to convert sqrt_price to u128"))?);
            tables.create_row("raydium_clmm_create_pool_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("amm", &create_pool.amm)
                .set("creator", &create_pool.creator)
                .set("token0_mint", &create_pool.token0_mint)
                .set("token1_mint", &create_pool.token1_mint)
                .set("token0_vault", &create_pool.token0_vault)
                .set("token1_vault", &create_pool.token1_vault)
                .set("token0_program", &create_pool.token0_program)
                .set("token1_program", &create_pool.token1_program)
                .set("sqrt_price", sqrt_price.to_string())
                .set("open_time", create_pool.open_time)
        }
        _ => return Ok(None),
    };
    Ok(Some((row, false)))
}

fn parse_raydium_amm_instruction<'a>(
    instruction: &IndexedInstruction,
    context: &TransactionContext,
    tables: &'a mut Tables,
    slot: u64,
    transaction_index: u32,
) -> Result<Option<(&'a mut Row, bool)>, Error> {
    let row = match raydium_amm_substream::parse_instruction(&instruction.instruction, context).map_err(|x| anyhow!(x))? {
        Some(raydium_amm_event::Event::Swap(swap)) => {
            tables.create_row("raydium_amm_swap_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("amm", &swap.amm)
                .set("user", &swap.user)
                .set("amount_in", swap.amount_in)
                .set("amount_out", swap.amount_out)
                .set("mint_in", &swap.mint_in)
                .set("mint_out", &swap.mint_out)
                .set("direction", &swap.direction)
                .set("pool_pc_amount", swap.pool_pc_amount.unwrap_or(0))
                .set("pool_coin_amount", swap.pool_coin_amount.unwrap_or(0))
                .set("user_pre_balance_in", swap.user_pre_balance_in.unwrap_or(0))
                .set("user_pre_balance_out", swap.user_pre_balance_out.unwrap_or(0))
        }
        Some(raydium_amm_event::Event::Initialize(initialize)) => {
            tables.create_row("raydium_amm_initialize_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("amm", &initialize.amm)
                .set("user", &initialize.user)
                .set("pc_init_amount", initialize.pc_init_amount)
                .set("coin_init_amount", initialize.coin_init_amount)
                .set("lp_init_amount", initialize.lp_init_amount)
                .set("pc_mint", &initialize.pc_mint)
                .set("coin_mint", &initialize.coin_mint)
                .set("lp_mint", &initialize.lp_mint)
                .set("user_pc_pre_balance", initialize.user_pc_pre_balance.unwrap_or(0))
                .set("user_coin_pre_balance", initialize.user_coin_pre_balance.unwrap_or(0))
        },
        Some(raydium_amm_event::Event::Deposit(deposit)) => {
            tables.create_row("raydium_amm_deposit_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("amm", &deposit.amm)
                .set("user", &deposit.user)
                .set("pc_amount", deposit.pc_amount)
                .set("coin_amount", deposit.coin_amount)
                .set("pool_pc_amount", deposit.pool_pc_amount.unwrap_or(0))
                .set("pool_coin_amount", deposit.pool_coin_amount.unwrap_or(0))
                .set("lp_amount", deposit.lp_amount)
                .set("pc_mint", &deposit.pc_mint)
                .set("coin_mint", &deposit.coin_mint)
                .set("lp_mint", &deposit.lp_mint)
                .set("user_pc_pre_balance", deposit.user_pc_pre_balance.unwrap_or(0))
                .set("user_coin_pre_balance", deposit.user_coin_pre_balance.unwrap_or(0))
        },
        Some(raydium_amm_event::Event::Withdraw(withdraw)) => {
            tables.create_row("raydium_amm_withdraw_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("amm", &withdraw.amm)
                .set("user", &withdraw.user)
                .set("pc_amount", withdraw.pc_amount)
                .set("coin_amount", withdraw.coin_amount)
                .set("pool_pc_amount", withdraw.pool_pc_amount.unwrap_or(0))
                .set("pool_coin_amount", withdraw.pool_coin_amount.unwrap_or(0))
                .set("lp_amount", withdraw.lp_amount)
                .set("pc_mint", &withdraw.pc_mint)
                .set("coin_mint", &withdraw.coin_mint)
                .set("lp_mint", &withdraw.lp_mint)
                .set("user_pc_pre_balance", withdraw.user_pc_pre_balance.unwrap_or(0))
                .set("user_coin_pre_balance", withdraw.user_coin_pre_balance.unwrap_or(0))
        },
        Some(raydium_amm_event::Event::WithdrawPnl(withdraw_pnl)) => {
            tables.create_row("raydium_amm_withdraw_pnl_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("amm", withdraw_pnl.amm)
                .set("user", withdraw_pnl.user)
                .set("pc_amount", withdraw_pnl.pc_amount.unwrap_or(0))
                .set("coin_amount", withdraw_pnl.coin_amount.unwrap_or(0))
                .set("pc_mint", withdraw_pnl.pc_mint.unwrap_or("".to_string()))
                .set("coin_mint", withdraw_pnl.coin_mint.unwrap_or("".to_string()))
        }
        _ => return Ok(None),
    };
    Ok(Some((row, false)))
}

fn parse_pumpfun_instruction<'a>(
    instruction: &IndexedInstruction,
    context: &TransactionContext,
    tables: &'a mut Tables,
    slot: u64,
    transaction_index: u32,
) -> Result<Option<(&'a mut Row, bool)>, Error> {
    let row = match pumpfun_substream::parse_instruction(&instruction.instruction, context)? {
        Some(pumpfun_event::Event::Create(create)) => {
            tables.create_row("pumpfun_create_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("user", create.user)
                .set("name", create.name)
                .set("symbol", create.symbol)
                .set("uri", create.uri)
                .set("mint", create.mint)
                .set("bonding_curve", create.bonding_curve)
                .set("associated_bonding_curve", create.associated_bonding_curve)
                .set("metadata", create.metadata)
        },
        Some(pumpfun_event::Event::Initialize(initialize)) => {
            tables.create_row("pumpfun_initialize_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("user", initialize.user)
        },
        Some(pumpfun_event::Event::SetParams(set_params)) => {
            tables.create_row("pumpfun_set_params_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("user", set_params.user)
                .set("fee_recipient", set_params.fee_recipient)
                .set("initial_virtual_token_reserves", set_params.initial_virtual_token_reserves)
                .set("initial_virtual_sol_reserves", set_params.initial_virtual_sol_reserves)
                .set("initial_real_token_reserves", set_params.initial_real_token_reserves)
                .set("token_total_supply", set_params.token_total_supply)
                .set("fee_basis_points", set_params.fee_basis_points)
        },
        Some(pumpfun_event::Event::Swap(swap)) => {
            tables.create_row("pumpfun_swap_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("user", swap.user)
                .set("mint", swap.mint)
                .set("bonding_curve", swap.bonding_curve)
                .set("token_amount", swap.token_amount)
                .set("direction", swap.direction)
                .set("sol_amount", swap.sol_amount.unwrap_or(0))
                .set("virtual_sol_reserves", swap.virtual_sol_reserves.unwrap_or(0))
                .set("virtual_token_reserves", swap.virtual_token_reserves.unwrap_or(0))
                .set("real_sol_reserves", swap.real_sol_reserves.unwrap_or(0))
                .set("real_token_reserves", swap.real_token_reserves.unwrap_or(0))
        },
        Some(pumpfun_event::Event::Withdraw(withdraw)) => {
            tables.create_row("pumpfun_withdraw_events", [("slot", slot.to_string()), ("transaction_index", transaction_index.to_string()), ("instruction_index", instruction.index.to_string())])
                .set("mint", withdraw.mint)
        },
        None => return Ok(None)
    };
    Ok(Some((row, false)))
}
