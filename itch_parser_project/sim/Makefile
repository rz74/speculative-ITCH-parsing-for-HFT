TOPLEVEL_LANG = verilog
MODULE = test_itch_parser
SIM = icarus

# Switch here to test different versions
# Options: itch_parser, itch_parser_speculative
TOPLEVEL = itch_parser
# TOPLEVEL = itch_parser_speculative

ifeq ($(TOPLEVEL),itch_parser)
    VERILOG_SOURCES = ../rtl/itch_parser.v
else ifeq ($(TOPLEVEL),itch_parser_speculative)
    VERILOG_SOURCES = ../rtl/itch_parser_speculative.v
else
    $(error Unknown TOPLEVEL value)
endif

include $(shell cocotb-config --makefiles)/Makefile.sim
