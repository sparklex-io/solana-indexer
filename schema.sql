BEGIN;

-- BLOCKS
CREATE TABLE IF NOT EXISTS blocks
(
    slot NUMERIC(78,0),
    parent_slot NUMERIC(78,0),
    block_height NUMERIC(78,0),
    blockhash TEXT,
    previous_blockhash TEXT,
    block_time TIMESTAMP,
    insertion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (slot)
);

-- TRANSACTIONS
CREATE TABLE IF NOT EXISTS transactions
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    signature TEXT,
    number_of_signers SMALLINT,
    signer0 TEXT,
    signer1 TEXT DEFAULT '',
    signer2 TEXT DEFAULT '',
    signer3 TEXT DEFAULT '',
    signer4 TEXT DEFAULT '',
    signer5 TEXT DEFAULT '',
    signer6 TEXT DEFAULT '',
    signer7 TEXT DEFAULT '',
    -- signers TEXT[], -- Array alternative if needed
    PRIMARY KEY (slot, transaction_index)
);

-- Create index for signature lookups (replaces ClickHouse's PROJECTION)
CREATE INDEX IF NOT EXISTS idx_transactions_signature ON transactions (signature);

-- Create partition (optional, requires PostgreSQL 10+)
CREATE TABLE IF NOT EXISTS transactions_partition_template (LIKE transactions INCLUDING ALL)
PARTITION BY RANGE (slot);

-- RAYDIUM AMM EVENTS
CREATE TABLE IF NOT EXISTS raydium_amm_swap_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    amm TEXT,
    "user" TEXT,
    amount_in NUMERIC(78,0),
    amount_out NUMERIC(78,0),
    mint_in TEXT,
    mint_out TEXT,
    direction TEXT,
    pool_pc_amount NUMERIC(78,0),
    pool_coin_amount NUMERIC(78,0),
    user_pre_balance_in NUMERIC(78,0),
    user_pre_balance_out NUMERIC(78,0),
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create indexes to replace ClickHouse PROJECTIONS
CREATE INDEX IF NOT EXISTS idx_raydium_amm_swap_events_amm ON raydium_amm_swap_events (amm, slot, transaction_index, instruction_index);
CREATE INDEX IF NOT EXISTS idx_raydium_amm_swap_events_user ON raydium_amm_swap_events ("user", slot, transaction_index, instruction_index);
CREATE INDEX IF NOT EXISTS idx_raydium_amm_swap_events_mint_in ON raydium_amm_swap_events (mint_in, slot, transaction_index, instruction_index);
CREATE INDEX IF NOT EXISTS idx_raydium_amm_swap_events_mint_out ON raydium_amm_swap_events (mint_out, slot, transaction_index, instruction_index);

CREATE TABLE IF NOT EXISTS raydium_amm_initialize_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    amm TEXT,
    "user" TEXT,
    pc_init_amount NUMERIC(78,0),
    coin_init_amount NUMERIC(78,0),
    lp_init_amount NUMERIC(78,0),
    pc_mint TEXT,
    coin_mint TEXT,
    lp_mint TEXT,
    user_pc_pre_balance NUMERIC(78,0),
    user_coin_pre_balance NUMERIC(78,0),
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create indexes to replace ClickHouse PROJECTIONS
CREATE INDEX IF NOT EXISTS idx_raydium_amm_initialize_events_amm ON raydium_amm_initialize_events (amm, slot, transaction_index, instruction_index);
CREATE INDEX IF NOT EXISTS idx_raydium_amm_initialize_events_user ON raydium_amm_initialize_events ("user", slot, transaction_index, instruction_index);

CREATE TABLE IF NOT EXISTS raydium_amm_deposit_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    amm TEXT,
    "user" TEXT,
    pc_amount NUMERIC(78,0),
    coin_amount NUMERIC(78,0),
    pool_pc_amount NUMERIC(78,0),
    pool_coin_amount NUMERIC(78,0),
    lp_amount NUMERIC(78,0),
    pc_mint TEXT,
    coin_mint TEXT,
    lp_mint TEXT,
    user_pc_pre_balance NUMERIC(78,0),
    user_coin_pre_balance NUMERIC(78,0),
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create indexes to replace ClickHouse PROJECTIONS
CREATE INDEX IF NOT EXISTS idx_raydium_amm_deposit_events_amm ON raydium_amm_deposit_events (amm, slot, transaction_index, instruction_index);
CREATE INDEX IF NOT EXISTS idx_raydium_amm_deposit_events_user ON raydium_amm_deposit_events ("user", slot, transaction_index, instruction_index);
CREATE INDEX IF NOT EXISTS idx_raydium_amm_deposit_events_pc_mint ON raydium_amm_deposit_events (pc_mint, slot, transaction_index, instruction_index);
CREATE INDEX IF NOT EXISTS idx_raydium_amm_deposit_events_coin_mint ON raydium_amm_deposit_events (coin_mint, slot, transaction_index, instruction_index);

CREATE TABLE IF NOT EXISTS raydium_amm_withdraw_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    amm TEXT,
    "user" TEXT,
    pc_amount NUMERIC(78,0),
    coin_amount NUMERIC(78,0),
    lp_amount NUMERIC(78,0),
    pool_pc_amount NUMERIC(78,0),
    pool_coin_amount NUMERIC(78,0),
    pc_mint TEXT,
    coin_mint TEXT,
    lp_mint TEXT,
    user_pc_pre_balance NUMERIC(78,0),
    user_coin_pre_balance NUMERIC(78,0),
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create indexes to replace ClickHouse PROJECTIONS
CREATE INDEX IF NOT EXISTS idx_raydium_amm_withdraw_events_amm ON raydium_amm_withdraw_events (amm, slot, transaction_index, instruction_index);
CREATE INDEX IF NOT EXISTS idx_raydium_amm_withdraw_events_user ON raydium_amm_withdraw_events ("user", slot, transaction_index, instruction_index);
CREATE INDEX IF NOT EXISTS idx_raydium_amm_withdraw_events_pc_mint ON raydium_amm_withdraw_events (pc_mint, slot, transaction_index, instruction_index);
CREATE INDEX IF NOT EXISTS idx_raydium_amm_withdraw_events_coin_mint ON raydium_amm_withdraw_events (coin_mint, slot, transaction_index, instruction_index);

CREATE TABLE IF NOT EXISTS raydium_amm_withdraw_pnl_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    amm TEXT,
    "user" TEXT,
    pc_amount NUMERIC(78,0),
    coin_amount NUMERIC(78,0),
    pc_mint TEXT,
    coin_mint TEXT,
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create indexes to replace ClickHouse PROJECTIONS
CREATE INDEX IF NOT EXISTS idx_raydium_amm_withdraw_pnl_events_amm ON raydium_amm_withdraw_pnl_events (amm, slot, transaction_index, instruction_index);
CREATE INDEX IF NOT EXISTS idx_raydium_amm_withdraw_pnl_events_user ON raydium_amm_withdraw_pnl_events ("user", slot, transaction_index, instruction_index);
CREATE INDEX IF NOT EXISTS idx_raydium_amm_withdraw_pnl_events_pc_mint ON raydium_amm_withdraw_pnl_events (pc_mint, slot, transaction_index, instruction_index);
CREATE INDEX IF NOT EXISTS idx_raydium_amm_withdraw_pnl_events_coin_mint ON raydium_amm_withdraw_pnl_events (coin_mint, slot, transaction_index, instruction_index);

-- PUMPFUN
CREATE TABLE IF NOT EXISTS pumpfun_create_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    "user" TEXT,
    name TEXT,
    symbol TEXT,
    uri TEXT,
    mint TEXT,
    bonding_curve TEXT,
    associated_bonding_curve TEXT,
    metadata TEXT,
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

CREATE TABLE IF NOT EXISTS pumpfun_initialize_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    "user" TEXT,
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

CREATE TABLE IF NOT EXISTS pumpfun_set_params_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    "user" TEXT,
    fee_recipient TEXT,
    initial_virtual_token_reserves NUMERIC(78,0),
    initial_virtual_sol_reserves NUMERIC(78,0),
    initial_real_token_reserves NUMERIC(78,0),
    token_total_supply NUMERIC(78,0),
    fee_basis_points NUMERIC(78,0),
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

CREATE TABLE IF NOT EXISTS pumpfun_swap_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    "user" TEXT,
    mint TEXT,
    bonding_curve TEXT,
    token_amount NUMERIC(78,0),
    direction TEXT,
    sol_amount NUMERIC(78,0),
    virtual_sol_reserves NUMERIC(78,0),
    virtual_token_reserves NUMERIC(78,0),
    real_sol_reserves NUMERIC(78,0),
    real_token_reserves NUMERIC(78,0),
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

CREATE TABLE IF NOT EXISTS pumpfun_withdraw_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    mint TEXT,
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

COMMIT;