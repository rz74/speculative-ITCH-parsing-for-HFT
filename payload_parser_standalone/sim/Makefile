TOPLEVEL_LANG = verilog
VERILOG_SOURCES = ../rtl/payload_dispatcher.v ../rtl/add_order_decoder.v ../synth/top.v
TOPLEVEL = top
MODULE = test_payload_parser
SIM = icarus

COMPILE_ARGS += -g2012 -DCOCOTB_SIM

include $(shell cocotb-config --makefiles)/Makefile.sim
