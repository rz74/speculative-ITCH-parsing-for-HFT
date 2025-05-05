# sim_config.py

# Define global simulation period in ns  
SIM_CLK_PERIOD_NS = 10  
RESET_CYCLES = 3  # Number of cycles to reset the DUT before starting the test
MSG_SEQUENCE = ['replace', 'delete', 'replace', 'replace', 'delete'] # message sequence for testing

# Define common headers to enforce identical CSV structure
SIM_HEADERS = [
    "cycle",
    
    "add_internal_valid",
    "cancel_internal_valid",
    
    "add_order_ref",
    "add_shares",
    "add_price",
    "add_side",
    
    "cancel_order_ref",
    "cancel_shares",
    
    "delete_internal_valid",
    "delete_order_ref",

    "replace_internal_valid",
    "replace_old_order_ref",
    "replace_new_order_ref",
    "replace_shares",
    "replace_price",


]