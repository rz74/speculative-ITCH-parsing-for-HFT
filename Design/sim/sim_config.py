# sim_config.py

# Define global simulation period in ns  
SIM_CLK_PERIOD_NS = 10  
SIM_CYCLES = 300  # Number of cycles to run the simulation--placeholder
RESET_CYCLES = 3  # Number of cycles to reset the DUT before starting the test
MSG_MODE = 'set'  # Message mode for payload generation (set or rand)

# MSG_SEQUENCE = ['trade', 'trade', 'executed', 'executed', 'delete'] # message sequence for testing
MSG_SEQUENCE = [
    'add',
    'add', 
    'cancel',
    'cancel', 
    'replace', 
    'delete', 
    'trade',
    'replace', 
    'delete', 
    'trade',
    'trade',
    'trade',
    'add', 
    'cancel',
    'executed',
    'trade', 
    'trade'
    ] # message sequence for testing
# MSG_SEQUENCE = ['add', 'cancel', 'delete', 'trade', 'replace', 'replace', 'executed', 'trade'] # message sequence for testing





# Define message lengths for each type of message
# These lengths are based on the ITCH protocol specification
MSG_LENGTHS = {
    "add": 36,
    "cancel": 23,
    "replace": 27,
    "delete": 9,
    "executed": 30,
    "trade": 40
}

SIM_CYCLES = sum(MSG_LENGTHS[msg] for msg in MSG_SEQUENCE) + RESET_CYCLES + 20  # Total cycles to run the simulation

# Define common headers to enforce identical CSV structure
SIM_HEADERS = [
    "cycle",
    
    "add_internal_valid",
    "cancel_internal_valid",
    "delete_internal_valid",
    "replace_internal_valid",
    "executed_internal_valid", 
    
    "add_order_ref",
    "add_shares",
    "add_price",
    "add_side",
    
    "cancel_order_ref",
    "cancel_shares",
        
    "delete_order_ref",
    
    "replace_old_order_ref",
    "replace_new_order_ref",
    "replace_shares",
    "replace_price",

    "exec_timestamp",
    "exec_order_ref",
    "exec_shares",
    "exec_match_id",

    "trade_internal_valid",
    "trade_timestamp",
    "trade_order_ref",
    "trade_side",
    "trade_shares",
    "trade_stock_symbol",
    "trade_price",
    "trade_match_id"

]