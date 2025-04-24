TOPLEVEL_LANG = verilog
MODULE = test_fifo
SIM = icarus

TOPLEVEL = fifo

VERILOG_SOURCES = ../rtl/fifo.v
DUMPFILE = waveform.vcd
COMPILE_ARGS += -DCOCOTB_SIM=1

include $(shell cocotb-config --makefiles)/Makefile.sim
