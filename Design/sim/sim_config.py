# sim_config.py
# Configuration file for the simulation environment
from helpers.msg_sequence_helper import generate_msg_sequence, generate_permutation_coverage_sequence
from ITCH_config import MSG_LENGTHS, SIM_HEADERS

# Define global simulation period in ns  
SIM_CLK_PERIOD_NS = 10  
SIM_CYCLES = 300  # Number of cycles to run the simulation--placeholder
RESET_CYCLES = 3  # Number of cycles to reset the DUT before starting the test
MSG_MODE = 'rand'  # Message mode for payload generation (set or rand)

# MSG_SEQUENCE = generate_msg_sequence(40)
MSG_SEQUENCE = generate_permutation_coverage_sequence()  # permutation coverage sequence  

# 
# MSG_SEQUENCE = [    'delete',     'delete',     'add'    ] # message sequence for testing



# Total cycles to run the simulation
SIM_CYCLES = sum(MSG_LENGTHS[msg] for msg in MSG_SEQUENCE) + RESET_CYCLES + 20  