TOPLEVEL_LANG = verilog
MODULE = test_itch_parser
SIM = icarus

# Set the actual DUT module (used by cocotb to hook into signals)
TOPLEVEL = itch_parser

# Include both the DUT and the waveform-dumping wrapper
VERILOG_SOURCES = ../rtl/itch_parser.v tb_wrapper.v

# Enable VCD waveform dumping
DUMPFILE = waveform.vcd

# Include cocotb's default rules
include $(shell cocotb-config --makefiles)/Makefile.sim
