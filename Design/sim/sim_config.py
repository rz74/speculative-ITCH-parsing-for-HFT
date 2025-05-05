# sim_config.py
from helpers.msg_sequence_helper import generate_msg_sequence
from ITCH_config import MSG_LENGTHS, SIM_HEADERS
# Define global simulation period in ns  
SIM_CLK_PERIOD_NS = 10  
SIM_CYCLES = 300  # Number of cycles to run the simulation--placeholder
RESET_CYCLES = 3  # Number of cycles to reset the DUT before starting the test
MSG_MODE = 'set'  # Message mode for payload generation (set or rand)

MSG_SEQUENCE = generate_msg_sequence(20)   

SIM_CYCLES = sum(MSG_LENGTHS[msg] for msg in MSG_SEQUENCE) + RESET_CYCLES + 20  # Total cycles to run the simulation



