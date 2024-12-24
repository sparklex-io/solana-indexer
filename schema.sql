-- FUNCTIONS

-- BLOCKS

CREATE TABLE blocks
(
    slot BIGINT,
    parent_slot BIGINT,
    block_height BIGINT,
    blockhash TEXT,
    previous_blockhash TEXT,
    block_time TIMESTAMP,
    insertion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (slot)
);

-- TRANSACTIONS

CREATE TABLE transactions
(
    slot BIGINT,
    transaction_index BIGINT,
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
    slot BIGINT,
    transaction_index BIGINT,
    instruction_index BIGINT,
    partial_signature TEXT,
    partial_blockhash TEXT,
    amm TEXT,
    user TEXT,
    amount_in BIGINT,
    amount_out BIGINT,
    mint_in TEXT,
    mint_out TEXT,
    direction TEXT,
    pool_pc_amount BIGINT,
    pool_coin_amount BIGINT,
    user_pre_balance_in BIGINT,
    user_pre_balance_out BIGINT,
    parent_instruction_index BIGINT DEFAULT -1,
    top_instruction_index BIGINT DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create indexes to replace ClickHouse PROJECTIONS
CREATE INDEX idx_raydium_amm_swap_events_amm ON raydium_amm_swap_events (amm, slot, transaction_index, instruction_index);
CREATE INDEX idx_raydium_amm_swap_events_user ON raydium_amm_swap_events (user, slot, transaction_index, instruction_index);
CREATE INDEX idx_raydium_amm_swap_events_mint_in ON raydium_amm_swap_events (mint_in, slot, transaction_index, instruction_index);
CREATE INDEX idx_raydium_amm_swap_events_mint_out ON raydium_amm_swap_events (mint_out, slot, transaction_index, instruction_index);

CREATE TABLE raydium_amm_initialize_events
(
    slot BIGINT,
    transaction_index BIGINT,
    instruction_index BIGINT,
    partial_signature TEXT,
    partial_blockhash TEXT,
    amm TEXT,
    user TEXT,
    pc_init_amount BIGINT,
    coin_init_amount BIGINT,
    lp_init_amount BIGINT,
    pc_mint TEXT,
    coin_mint TEXT,
    lp_mint TEXT,
    user_pc_pre_balance BIGINT,
    user_coin_pre_balance BIGINT,
    parent_instruction_index BIGINT DEFAULT -1,
    top_instruction_index BIGINT DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create indexes to replace ClickHouse PROJECTIONS
CREATE INDEX idx_raydium_amm_initialize_events_amm ON raydium_amm_initialize_events (amm, slot, transaction_index, instruction_index);
CREATE INDEX idx_raydium_amm_initialize_events_user ON raydium_amm_initialize_events (user, slot, transaction_index, instruction_index);

CREATE TABLE raydium_amm_deposit_events
(
    slot BIGINT,
    transaction_index BIGINT,
    instruction_index BIGINT,
    partial_signature TEXT,
    partial_blockhash TEXT,
    amm TEXT,
    user TEXT,
    pc_amount BIGINT,
    coin_amount BIGINT,
    pool_pc_amount BIGINT,
    pool_coin_amount BIGINT,
    lp_amount BIGINT,
    pc_mint TEXT,
    coin_mint TEXT,
    lp_mint TEXT,
    user_pc_pre_balance BIGINT,
    user_coin_pre_balance BIGINT,
    parent_instruction_index BIGINT DEFAULT -1,
    top_instruction_index BIGINT DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create indexes to replace ClickHouse PROJECTIONS
CREATE INDEX idx_raydium_amm_deposit_events_amm ON raydium_amm_deposit_events (amm, slot, transaction_index, instruction_index);
CREATE INDEX idx_raydium_amm_deposit_events_user ON raydium_amm_deposit_events (user, slot, transaction_index, instruction_index);
CREATE INDEX idx_raydium_amm_deposit_events_pc_mint ON raydium_amm_deposit_events (pc_mint, slot, transaction_index, instruction_index);
CREATE INDEX idx_raydium_amm_deposit_events_coin_mint ON raydium_amm_deposit_events (coin_mint, slot, transaction_index, instruction_index);

CREATE TABLE raydium_amm_withdraw_events
(
    slot BIGINT,
    transaction_index BIGINT,
    instruction_index BIGINT,
    partial_signature TEXT,
    partial_blockhash TEXT,
    amm TEXT,
    user TEXT,
    pc_amount BIGINT,
    coin_amount BIGINT,
    lp_amount BIGINT,
    pool_pc_amount BIGINT,
    pool_coin_amount BIGINT,
    pc_mint TEXT,
    coin_mint TEXT,
    lp_mint TEXT,
    user_pc_pre_balance BIGINT,
    user_coin_pre_balance BIGINT,
    parent_instruction_index BIGINT DEFAULT -1,
    top_instruction_index BIGINT DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create indexes to replace ClickHouse PROJECTIONS
CREATE INDEX idx_raydium_amm_withdraw_events_amm ON raydium_amm_withdraw_events (amm, slot, transaction_index, instruction_index);
CREATE INDEX idx_raydium_amm_withdraw_events_user ON raydium_amm_withdraw_events (user, slot, transaction_index, instruction_index);
CREATE INDEX idx_raydium_amm_withdraw_events_pc_mint ON raydium_amm_withdraw_events (pc_mint, slot, transaction_index, instruction_index);
CREATE INDEX idx_raydium_amm_withdraw_events_coin_mint ON raydium_amm_withdraw_events (coin_mint, slot, transaction_index, instruction_index);

CREATE TABLE raydium_amm_withdraw_pnl_events
(
    slot BIGINT,
    transaction_index BIGINT,
    instruction_index BIGINT,
    partial_signature TEXT,
    partial_blockhash TEXT,
    amm TEXT,
    user TEXT,
    pc_amount BIGINT,
    coin_amount BIGINT,
    pc_mint TEXT,
    coin_mint TEXT,
    parent_instruction_index BIGINT DEFAULT -1,
    top_instruction_index BIGINT DEFAULT -1,
    parent_instruction_program_id TEXT DEFAULT '',
    top_instruction_program_id TEXT DEFAULT '',
    PRIMARY KEY (slot, transaction_index, instruction_index)
);

-- Create indexes to replace ClickHouse PROJECTIONS
CREATE INDEX idx_raydium_amm_withdraw_pnl_events_amm ON raydium_amm_withdraw_pnl_events (amm, slot, transaction_index, instruction_index);
CREATE INDEX idx_raydium_amm_withdraw_pnl_events_user ON raydium_amm_withdraw_pnl_events (user, slot, transaction_index, instruction_index);
CREATE INDEX idx_raydium_amm_withdraw_pnl_events_pc_mint ON raydium_amm_withdraw_pnl_events (pc_mint, slot, transaction_index, instruction_index);
CREATE INDEX idx_raydium_amm_withdraw_pnl_events_coin_mint ON raydium_amm_withdraw_pnl_events (coin_mint, slot, transaction_index, instruction_index);

-- SPL TOKEN EVENTS

CREATE TABLE spl_token_initialize_mint_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    mint LowCardinality(String) CODEC(LZ4),
    decimals UInt64,
    mint_authority LowCardinality(String) CODEC(LZ4),
    freeze_authority LowCardinality(String) CODEC(LZ4),
    PROJECTION projection_mint (SELECT * ORDER BY mint, slot, transaction_index, instruction_index), -- RECOMMENDED
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_initialize_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    account_address LowCardinality(String) CODEC(LZ4),
    account_owner LowCardinality(String) CODEC(LZ4),
    mint LowCardinality(String) CODEC(LZ4),
    -- PROJECTION projection_owner (SELECT * ORDER BY account_owner),
    -- PROJECTION projection_mint (SELECT * ORDER BY mint),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PARTITION BY toInt64(slot / 4e6)
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_initialize_multisig_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    multisig String CODEC(LZ4),
    -- signers Array(LowCardinality(String)) CODEC(LZ4),
    m UInt64,
    -- PROJECTION projection_multisig (SELECT * ORDER BY multisig),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_transfer_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    source_address LowCardinality(String) CODEC(LZ4),
    source_owner LowCardinality(String) CODEC(LZ4),
    source_pre_balance UInt64,
    destination_address LowCardinality(String) CODEC(LZ4),
    destination_owner LowCardinality(String) CODEC(LZ4),
    destination_pre_balance UInt64,
    mint LowCardinality(String) CODEC(LZ4),
    amount UInt64,
    authority LowCardinality(String) CODEC(LZ4),
    transfer_type LowCardinality(String) DEFAULT 'unknown' CODEC(LZ4),
    PROJECTION projection_mint (SELECT * ORDER BY mint, slot, transaction_index, instruction_index), -- RECOMMENDED
    PROJECTION projection_source (SELECT * ORDER BY source_owner, slot, transaction_index, instruction_index), -- RECOMMENDED
    PROJECTION projection_destination (SELECT * ORDER BY destination_owner, slot, transaction_index, instruction_index), -- RECOMMENDED
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PARTITION BY toInt64(slot / 1e6)
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_approve_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    source_address LowCardinality(String) CODEC(LZ4),
    source_owner LowCardinality(String) CODEC(LZ4),
    mint LowCardinality(String) CODEC(LZ4),
    delegate LowCardinality(String) CODEC(LZ4),
    amount UInt64,
    -- PROJECTION projection_mint (SELECT * ORDER BY mint),
    -- PROJECTION projection_owner (SELECT * ORDER BY source_owner),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_revoke_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    source_address LowCardinality(String) CODEC(LZ4),
    source_owner LowCardinality(String) CODEC(LZ4),
    mint LowCardinality(String) CODEC(LZ4),
    -- PROJECTION projection_mint (SELECT * ORDER BY mint),
    -- PROJECTION projection_owner (SELECT * ORDER BY source_owner),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_set_authority_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    mint LowCardinality(String) CODEC(LZ4),
    authority_type LowCardinality(VARCHAR(14)) CODEC(LZ4),
    new_authority LowCardinality(String) CODEC(LZ4),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_mint_to_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    destination_address LowCardinality(String) CODEC(LZ4),
    destination_owner LowCardinality(String) CODEC(LZ4),
    destination_pre_balance UInt64,
    mint LowCardinality(String) CODEC(LZ4),
    mint_authority LowCardinality(String) CODEC(LZ4),
    amount UInt64,
    PROJECTION projection_mint (SELECT * ORDER BY mint, slot, transaction_index, instruction_index), -- RECOMMENDED
    PROJECTION projection_destination (SELECT * ORDER BY destination_owner, slot, transaction_index, instruction_index), -- RECOMMENDED
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PARTITION BY toInt64(slot / 32e6)
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_burn_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    source_address LowCardinality(String) CODEC(LZ4),
    source_owner LowCardinality(String) CODEC(LZ4),
    source_pre_balance UInt64,
    mint LowCardinality(String) CODEC(LZ4),
    authority LowCardinality(String) CODEC(LZ4),
    amount UInt64,
    PROJECTION projection_mint (SELECT * ORDER BY mint, slot, transaction_index, instruction_index), -- RECOMMENDED
    PROJECTION projection_source (SELECT * ORDER BY source_owner, slot, transaction_index, instruction_index), -- RECOMMENDED
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PARTITION BY toInt64(slot / 16e6)
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_close_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    source_address LowCardinality(String) CODEC(LZ4),
    source_owner LowCardinality(String) CODEC(LZ4),
    destination LowCardinality(String) CODEC(LZ4),
    mint LowCardinality(String),
    -- PROJECTION projection_mint (SELECT * ORDER BY mint),
    -- PROJECTION projection_source (SELECT * ORDER BY source_owner),
    -- PROJECTION projection_destination (SELECT * ORDER BY destination),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PARTITION BY toInt64(slot / 4e6)
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_freeze_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    source_address LowCardinality(String) CODEC(LZ4),
    source_owner LowCardinality(String) CODEC(LZ4),
    mint LowCardinality(String) CODEC(LZ4),
    freeze_authority LowCardinality(String) CODEC(LZ4),
    -- PROJECTION projection_mint (SELECT * ORDER BY mint),
    -- PROJECTION projection_source (SELECT * ORDER BY source_owner),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_thaw_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    source_address LowCardinality(String) CODEC(LZ4),
    source_owner LowCardinality(String) CODEC(LZ4),
    mint LowCardinality(String) CODEC(LZ4),
    freeze_authority LowCardinality(String) CODEC(LZ4),
    -- PROJECTION projection_mint (SELECT * ORDER BY mint),
    -- PROJECTION projection_source (SELECT * ORDER BY source_owner),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_initialize_immutable_owner_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    account_address LowCardinality(String) CODEC(LZ4),
    account_owner LowCardinality(String) CODEC(LZ4),
    mint LowCardinality(String) CODEC(LZ4),
    -- PROJECTION projection_mint (SELECT * ORDER BY mint),
    -- PROJECTION projection_owner (SELECT * ORDER BY account_owner),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PARTITION BY toInt64(slot / 8e6)
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_sync_native_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    account_address LowCardinality(String) CODEC(LZ4),
    account_owner LowCardinality(String) CODEC(LZ4),
    -- PROJECTION projection_owner (SELECT * ORDER BY account_owner),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

-- SYSTEM PROGRAM EVENTS

CREATE TABLE system_program_create_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    funding_account LowCardinality(String) CODEC(LZ4),
    new_account LowCardinality(String) CODEC(LZ4),
    lamports UInt64,
    space UInt64,
    owner LowCardinality(String) CODEC(LZ4),
    -- PROJECTION projection_funding_account (SELECT * ORDER BY funding_account),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PARTITION BY toInt64(slot / 4e6)
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_assign_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    assigned_account LowCardinality(String) CODEC(LZ4),
    owner LowCardinality(String) CODEC(LZ4),
    -- PROJECTION projectION_owner (SELECT * ORDER BY owner),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_transfer_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    funding_account LowCardinality(String) CODEC(LZ4),
    funding_account_pre_balance UInt64,
    funding_account_post_balance UInt64,
    recipient_account LowCardinality(String) CODEC(LZ4),
    recipient_account_pre_balance UInt64,
    recipient_account_post_balance UInt64,
    lamports UInt64,
    transfer_type LowCardinality(String) DEFAULT 'unknown' CODEC(LZ4),
    PROJECTION projection_funding_account (SELECT * ORDER BY funding_account, slot, transaction_index, instruction_index), -- RECOMMENDED
    PROJECTION projection_recipient_account (SELECT * ORDER BY recipient_account, slot, transaction_index, instruction_index), -- RECOMMENDED
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PARTITION BY toInt64(slot / 1e6)
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_create_account_with_seed_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    funding_account LowCardinality(String) CODEC(LZ4),
    created_account LowCardinality(String) CODEC(LZ4),
    base_account LowCardinality(String) CODEC(LZ4),
    seed String CODEC(LZ4),
    lamports UInt64,
    space UInt64,
    owner LowCardinality(String) CODEC(LZ4),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PARTITION BY toInt64(slot / 4e6)
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_advance_nonce_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    nonce_account LowCardinality(String) CODEC(LZ4),
    nonce_authority LowCardinality(String) CODEC(LZ4),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_withdraw_nonce_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    nonce_account LowCardinality(String) CODEC(LZ4),
    nonce_authority LowCardinality(String) CODEC(LZ4),
    recipient_account LowCardinality(String) CODEC(LZ4),
    lamports UInt64,
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_initialize_nonce_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    nonce_account LowCardinality(String) CODEC(LZ4),
    nonce_authority LowCardinality(String) CODEC(LZ4),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_authorize_nonce_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    nonce_account LowCardinality(String) CODEC(LZ4),
    nonce_authority LowCardinality(String) CODEC(LZ4),
    new_nonce_authority LowCardinality(String) CODEC(LZ4),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_allocate_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    account LowCardinality(String) CODEC(LZ4),
    space UInt64,
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_allocate_with_seed_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    allocated_account LowCardinality(String) CODEC(LZ4),
    base_account LowCardinality(String) CODEC(LZ4),
    seed String CODEC(LZ4),
    space UInt64,
    owner LowCardinality(String) CODEC(LZ4),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_assign_with_seed_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    assigned_account LowCardinality(String) CODEC(LZ4),
    base_account LowCardinality(String) CODEC(LZ4),
    seed String CODEC(LZ4),
    owner LowCardinality(String) CODEC(LZ4),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_transfer_with_seed_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    funding_account LowCardinality(String) CODEC(LZ4),
    funding_account_pre_balance UInt64,
    funding_account_post_balance UInt64,
    base_account LowCardinality(String) CODEC(LZ4),
    recipient_account LowCardinality(String) CODEC(LZ4),
    recipient_account_pre_balance UInt64,
    recipient_account_post_balance UInt64,
    lamports UInt64,
    from_seed String CODEC(LZ4),
    from_owner LowCardinality(String) CODEC(LZ4),
    transfer_type LowCardinality(String) DEFAULT 'unknown' CODEC(LZ4),
    PROJECTION projection_funding_account (SELECT * ORDER BY funding_account, slot, transaction_index, instruction_index), -- RECOMMENDED
    PROJECTION projection_recipient_account (SELECT * ORDER BY recipient_account, slot, transaction_index, instruction_index), -- RECOMMENDED
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE system_program_upgrade_nonce_account_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    nonce_account LowCardinality(String) CODEC(LZ4),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

-- PUMPFUN EVENTS

CREATE TABLE pumpfun_create_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    user LowCardinality(String) CODEC(LZ4),
    name String CODEC(LZ4),
    symbol String CODEC(LZ4),
    uri String CODEC(LZ4),
    mint LowCardinality(String) CODEC(LZ4),
    bonding_curve LowCardinality(String) CODEC(LZ4),
    associated_bonding_curve LowCardinality(String) CODEC(LZ4),
    metadata LowCardinality(String) CODEC(LZ4),
    PROJECTION projection_user (SELECT * ORDER BY user, slot, transaction_index, instruction_index), -- RECOMMENDED
    PROJECTION projection_mint (SELECT * ORDER BY mint, slot, transaction_index, instruction_index), -- RECOMMENDED
    -- PROJECTION projection_bonding_curve (SELECT * ORDER BY bonding_curve),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE pumpfun_initialize_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    user LowCardinality(String) CODEC(LZ4),
    -- PROJECTION projection_user (SELECT * ORDER BY user, slot, transaction_index, instruction_index),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE pumpfun_set_params_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    user LowCardinality(String) CODEC(LZ4),
    fee_recipient LowCardinality(String) CODEC(LZ4),
    initial_virtual_token_reserves UInt64,
    initial_virtual_sol_reserves UInt64,
    initial_real_token_reserves UInt64,
    token_total_supply UInt64,
    fee_basis_points UInt64,
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE pumpfun_swap_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    user LowCardinality(String) CODEC(LZ4),
    mint LowCardinality(String) CODEC(LZ4),
    bonding_curve LowCardinality(String) CODEC(LZ4),
    token_amount UInt64,
    direction String CODEC(LZ4),
    sol_amount UInt64,
    virtual_sol_reserves UInt64,
    virtual_token_reserves UInt64,
    real_sol_reserves UInt64,
    real_token_reserves UInt64,
    PROJECTION projection_mint (SELECT * ORDER BY mint, slot, transaction_index, instruction_index), -- RECOMMENDED
    PROJECTION projection_user (SELECT * ORDER BY user, slot, transaction_index, instruction_index), -- RECOMMENDED
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PARTITION BY toInt64(slot / 8e6)
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE pumpfun_withdraw_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    mint LowCardinality(String) CODEC(LZ4),
    PROJECTION projection_mint (SELECT * ORDER BY mint, slot, transaction_index, instruction_index), -- RECOMMENDED
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

-- MPL TOKEN METADATA EVENTS

CREATE TABLE mpl_token_metadata_create_metadata_account_v3_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    metadata String CODEC(LZ4),
    mint String CODEC(LZ4),
    update_authority String CODEC(LZ4),
    is_mutable Boolean,
    name String,
    symbol String,
    uri String,
    seller_fee_basis_points UInt64,
    PROJECTION projection_symbol (SELECT * ORDER BY symbol, slot, transaction_index, instruction_index), -- RECOMMENDED
    PROJECTION projection_mint (SELECT * ORDER BY mint, slot, transaction_index, instruction_index), -- RECOMMENDED
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE mpl_token_metadata_other_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    "type" String,
    -- PROJECTION projection_type (SELECT * ORDER BY "type"),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);
