-- FUNCTIONS

-- BLOCKS

CREATE TABLE blocks
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

CREATE TABLE transactions
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
CREATE INDEX idx_transactions_signature ON transactions (signature);

-- Create partition (optional, requires PostgreSQL 10+)
CREATE TABLE transactions_partition_template (LIKE transactions INCLUDING ALL)
PARTITION BY RANGE (slot);

-- RAYDIUM AMM EVENTS

CREATE TABLE raydium_amm_swap_events
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
CREATE INDEX idx_raydium_amm_swap_events_amm ON raydium_amm_swap_events (amm, slot, transaction_index, instruction_index);
CREATE INDEX idx_raydium_amm_swap_events_user ON raydium_amm_swap_events ("user", slot, transaction_index, instruction_index);
CREATE INDEX idx_raydium_amm_swap_events_mint_in ON raydium_amm_swap_events (mint_in, slot, transaction_index, instruction_index);
CREATE INDEX idx_raydium_amm_swap_events_mint_out ON raydium_amm_swap_events (mint_out, slot, transaction_index, instruction_index);

CREATE TABLE raydium_amm_initialize_events
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
CREATE INDEX idx_raydium_amm_initialize_events_amm ON raydium_amm_initialize_events (amm, slot, transaction_index, instruction_index);
CREATE INDEX idx_raydium_amm_initialize_events_user ON raydium_amm_initialize_events ("user", slot, transaction_index, instruction_index);

CREATE TABLE raydium_amm_deposit_events
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
CREATE INDEX idx_raydium_amm_deposit_events_amm ON raydium_amm_deposit_events (amm, slot, transaction_index, instruction_index);
CREATE INDEX idx_raydium_amm_deposit_events_user ON raydium_amm_deposit_events ("user", slot, transaction_index, instruction_index);
CREATE INDEX idx_raydium_amm_deposit_events_pc_mint ON raydium_amm_deposit_events (pc_mint, slot, transaction_index, instruction_index);
CREATE INDEX idx_raydium_amm_deposit_events_coin_mint ON raydium_amm_deposit_events (coin_mint, slot, transaction_index, instruction_index);

CREATE TABLE raydium_amm_withdraw_events
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
CREATE INDEX idx_raydium_amm_withdraw_events_amm ON raydium_amm_withdraw_events (amm, slot, transaction_index, instruction_index);
CREATE INDEX idx_raydium_amm_withdraw_events_user ON raydium_amm_withdraw_events ("user", slot, transaction_index, instruction_index);
CREATE INDEX idx_raydium_amm_withdraw_events_pc_mint ON raydium_amm_withdraw_events (pc_mint, slot, transaction_index, instruction_index);
CREATE INDEX idx_raydium_amm_withdraw_events_coin_mint ON raydium_amm_withdraw_events (coin_mint, slot, transaction_index, instruction_index);

CREATE TABLE raydium_amm_withdraw_pnl_events
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
CREATE INDEX idx_raydium_amm_withdraw_pnl_events_amm ON raydium_amm_withdraw_pnl_events (amm, slot, transaction_index, instruction_index);
CREATE INDEX idx_raydium_amm_withdraw_pnl_events_user ON raydium_amm_withdraw_pnl_events ("user", slot, transaction_index, instruction_index);
CREATE INDEX idx_raydium_amm_withdraw_pnl_events_pc_mint ON raydium_amm_withdraw_pnl_events (pc_mint, slot, transaction_index, instruction_index);
CREATE INDEX idx_raydium_amm_withdraw_pnl_events_coin_mint ON raydium_amm_withdraw_pnl_events (coin_mint, slot, transaction_index, instruction_index);

-- SPL TOKEN EVENTS

CREATE TABLE spl_token_initialize_mint_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    mint TEXT,
    decimals NUMERIC(78,0),
    mint_authority TEXT,
    freeze_authority TEXT,
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create index to replace ClickHouse PROJECTION
CREATE INDEX idx_spl_token_initialize_mint_events_mint 
ON spl_token_initialize_mint_events (mint, slot, transaction_index, instruction_index);

CREATE TABLE spl_token_initialize_account_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    account_address TEXT,
    account_owner TEXT,
    mint TEXT,
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create indexes to replace ClickHouse PROJECTIONS
CREATE INDEX idx_spl_token_initialize_account_events_owner ON spl_token_initialize_account_events (account_owner, slot, transaction_index, instruction_index);
CREATE INDEX idx_spl_token_initialize_account_events_mint ON spl_token_initialize_account_events (mint, slot, transaction_index, instruction_index);

CREATE TABLE spl_token_initialize_multisig_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    multisig TEXT,
    -- signers TEXT[], -- Array alternative if needed
    m NUMERIC(78,0),
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create index to replace ClickHouse PROJECTION
CREATE INDEX idx_spl_token_initialize_multisig_events_multisig ON spl_token_initialize_multisig_events (multisig, slot, transaction_index, instruction_index);

CREATE TABLE spl_token_transfer_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    source_address TEXT,
    source_owner TEXT,
    source_pre_balance NUMERIC(78,0),
    destination_address TEXT,
    destination_owner TEXT,
    destination_pre_balance NUMERIC(78,0),
    mint TEXT,
    amount NUMERIC(78,0),
    authority TEXT,
    transfer_type TEXT DEFAULT 'unknown',
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create indexes to replace ClickHouse PROJECTIONS
CREATE INDEX idx_spl_token_transfer_events_mint ON spl_token_transfer_events (mint, slot, transaction_index, instruction_index);
CREATE INDEX idx_spl_token_transfer_events_source ON spl_token_transfer_events (source_owner, slot, transaction_index, instruction_index);
CREATE INDEX idx_spl_token_transfer_events_destination ON spl_token_transfer_events (destination_owner, slot, transaction_index, instruction_index);

CREATE TABLE spl_token_approve_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    source_address TEXT,
    source_owner TEXT,
    mint TEXT,
    delegate TEXT,
    amount NUMERIC(78,0),
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create indexes to replace ClickHouse PROJECTIONS
CREATE INDEX idx_spl_token_approve_events_mint ON spl_token_approve_events (mint, slot, transaction_index, instruction_index);
CREATE INDEX idx_spl_token_approve_events_owner ON spl_token_approve_events (source_owner, slot, transaction_index, instruction_index);

CREATE TABLE spl_token_revoke_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    source_address TEXT,
    source_owner TEXT,
    mint TEXT,
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create indexes to replace ClickHouse PROJECTIONS
CREATE INDEX idx_spl_token_revoke_events_mint ON spl_token_revoke_events (mint, slot, transaction_index, instruction_index);
CREATE INDEX idx_spl_token_revoke_events_owner ON spl_token_revoke_events (source_owner, slot, transaction_index, instruction_index);

CREATE TABLE spl_token_set_authority_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    mint TEXT,
    authority_type VARCHAR(14),
    new_authority TEXT,
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create indexes to replace ClickHouse PROJECTIONS
CREATE INDEX idx_spl_token_set_authority_events_mint ON spl_token_set_authority_events (mint, slot, transaction_index, instruction_index);

CREATE TABLE spl_token_mint_to_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    destination_address TEXT,
    destination_owner TEXT,
    destination_pre_balance NUMERIC(78,0),
    mint TEXT,
    mint_authority TEXT,
    amount NUMERIC(78,0),
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create indexes to replace ClickHouse PROJECTIONS
CREATE INDEX idx_spl_token_mint_to_events_mint ON spl_token_mint_to_events (mint, slot, transaction_index, instruction_index);
CREATE INDEX idx_spl_token_mint_to_events_destination ON spl_token_mint_to_events (destination_owner, slot, transaction_index, instruction_index);

CREATE TABLE spl_token_burn_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    source_address TEXT,
    source_owner TEXT,
    source_pre_balance NUMERIC(78,0),
    mint TEXT,
    authority TEXT,
    amount NUMERIC(78,0),
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create indexes to replace ClickHouse PROJECTIONS
CREATE INDEX idx_spl_token_burn_events_mint ON spl_token_burn_events (mint, slot, transaction_index, instruction_index);
CREATE INDEX idx_spl_token_burn_events_source ON spl_token_burn_events (source_owner, slot, transaction_index, instruction_index);

CREATE TABLE spl_token_close_account_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    source_address TEXT,
    source_owner TEXT,
    destination TEXT,
    mint TEXT,
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create indexes to replace ClickHouse PROJECTIONS
CREATE INDEX idx_spl_token_close_account_events_mint ON spl_token_close_account_events (mint, slot, transaction_index, instruction_index);
CREATE INDEX idx_spl_token_close_account_events_source ON spl_token_close_account_events (source_owner, slot, transaction_index, instruction_index);
CREATE INDEX idx_spl_token_close_account_events_destination ON spl_token_close_account_events (destination, slot, transaction_index, instruction_index);

CREATE TABLE spl_token_freeze_account_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    source_address TEXT,
    source_owner TEXT,
    mint TEXT,
    freeze_authority TEXT,
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create indexes to replace ClickHouse PROJECTIONS
CREATE INDEX idx_spl_token_freeze_account_events_mint ON spl_token_freeze_account_events (mint, slot, transaction_index, instruction_index);
CREATE INDEX idx_spl_token_freeze_account_events_source ON spl_token_freeze_account_events (source_owner, slot, transaction_index, instruction_index);

CREATE TABLE spl_token_thaw_account_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    source_address TEXT,
    source_owner TEXT,
    mint TEXT,
    freeze_authority TEXT,
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create indexes to replace ClickHouse PROJECTIONS
CREATE INDEX idx_spl_token_thaw_account_events_mint ON spl_token_thaw_account_events (mint, slot, transaction_index, instruction_index);
CREATE INDEX idx_spl_token_thaw_account_events_source ON spl_token_thaw_account_events (source_owner, slot, transaction_index, instruction_index);

CREATE TABLE spl_token_initialize_immutable_owner_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    account_address TEXT,
    account_owner TEXT,
    mint TEXT,
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create indexes to replace ClickHouse PROJECTIONS
CREATE INDEX idx_spl_token_init_immutable_owner_events_mint ON spl_token_initialize_immutable_owner_events (mint, slot, transaction_index, instruction_index);
CREATE INDEX idx_spl_token_init_immutable_owner_events_owner ON spl_token_initialize_immutable_owner_events (account_owner, slot, transaction_index, instruction_index);

CREATE TABLE spl_token_sync_native_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    account_address TEXT,
    account_owner TEXT,
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create indexes to replace ClickHouse PROJECTIONS
CREATE INDEX idx_spl_token_sync_native_events_owner ON spl_token_sync_native_events (account_owner, slot, transaction_index, instruction_index);

-- SYSTEM PROGRAM EVENTS

CREATE TABLE system_program_create_account_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    funding_account TEXT,
    new_account TEXT,
    lamports NUMERIC(78,0),
    space NUMERIC(78,0),
    owner TEXT,
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create indexes to replace ClickHouse PROJECTIONS
CREATE INDEX idx_system_program_create_account_events_funding ON system_program_create_account_events (funding_account, slot, transaction_index, instruction_index);

CREATE TABLE system_program_assign_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    assigned_account TEXT,
    owner TEXT,
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create indexes to replace ClickHouse PROJECTIONS
CREATE INDEX idx_system_program_assign_events_owner ON system_program_assign_events (owner, slot, transaction_index, instruction_index);

CREATE TABLE system_program_transfer_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    funding_account TEXT,
    funding_account_pre_balance NUMERIC(78,0),
    funding_account_post_balance NUMERIC(78,0),
    recipient_account TEXT,
    recipient_account_pre_balance NUMERIC(78,0),
    recipient_account_post_balance NUMERIC(78,0),
    lamports NUMERIC(78,0),
    transfer_type TEXT DEFAULT 'unknown',
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create indexes to replace ClickHouse PROJECTIONS
CREATE INDEX idx_system_program_transfer_events_funding ON system_program_transfer_events (funding_account, slot, transaction_index, instruction_index);
CREATE INDEX idx_system_program_transfer_events_recipient ON system_program_transfer_events (recipient_account, slot, transaction_index, instruction_index);

CREATE TABLE system_program_create_account_with_seed_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    funding_account TEXT,
    created_account TEXT,
    base_account TEXT,
    seed TEXT,
    lamports NUMERIC(78,0),
    space NUMERIC(78,0),
    owner TEXT,
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

CREATE TABLE system_program_advance_nonce_account_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    nonce_account TEXT,
    nonce_authority TEXT,
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

CREATE TABLE system_program_withdraw_nonce_account_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    nonce_account TEXT,
    nonce_authority TEXT,
    recipient_account TEXT,
    lamports NUMERIC(78,0),
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

CREATE TABLE system_program_initialize_nonce_account_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    nonce_account TEXT,
    nonce_authority TEXT,
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

CREATE TABLE system_program_authorize_nonce_account_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    nonce_account TEXT,
    nonce_authority TEXT,
    new_nonce_authority TEXT,
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

CREATE TABLE system_program_allocate_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    account TEXT,
    space NUMERIC(78,0),
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

CREATE TABLE system_program_allocate_with_seed_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    allocated_account TEXT,
    base_account TEXT,
    seed TEXT,
    space NUMERIC(78,0),
    owner TEXT,
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

CREATE TABLE system_program_assign_with_seed_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    assigned_account TEXT,
    base_account TEXT,
    seed TEXT,
    owner TEXT,
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

CREATE TABLE system_program_transfer_with_seed_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    funding_account TEXT,
    funding_account_pre_balance NUMERIC(78,0),
    funding_account_post_balance NUMERIC(78,0),
    base_account TEXT,
    recipient_account TEXT,
    recipient_account_pre_balance NUMERIC(78,0),
    recipient_account_post_balance NUMERIC(78,0),
    lamports NUMERIC(78,0),
    from_seed TEXT,
    from_owner TEXT,
    transfer_type TEXT DEFAULT 'unknown',
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

CREATE TABLE system_program_upgrade_nonce_account_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    nonce_account TEXT,
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- PUMPFUN EVENTS

CREATE TABLE pumpfun_create_events
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

CREATE TABLE pumpfun_initialize_events
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

CREATE TABLE pumpfun_set_params_events
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

CREATE TABLE pumpfun_swap_events
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

CREATE TABLE pumpfun_withdraw_events
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

-- MPL TOKEN METADATA EVENTS

CREATE TABLE mpl_token_metadata_create_metadata_account_v3_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    metadata TEXT,
    mint TEXT,
    update_authority TEXT,
    is_mutable BOOLEAN,
    name TEXT,
    symbol TEXT,
    uri TEXT,
    seller_fee_basis_points NUMERIC(78,0),
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

CREATE TABLE mpl_token_metadata_other_events
(
    slot NUMERIC(78,0),
    transaction_index NUMERIC(78,0),
    instruction_index NUMERIC(78,0),
    partial_signature TEXT,
    partial_blockhash TEXT,
    "type" TEXT,
    parent_instruction_index NUMERIC(78,0) DEFAULT -1,
    top_instruction_index NUMERIC(78,0) DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);
