TOPLEVEL_LANG = verilog

VERILOG_SOURCES = \
    ../sim/top_test.v \
    ../rtl/add_order_decoder.v

TOPLEVEL = top_test
MODULE = test_add_order_decoder
SIM = verilator

COMPILE_ARGS += -DCOCOTB_SIM -DTEST_ADD_ORDER_DECODER

include $(shell cocotb-config --makefiles)/Makefile.sim

run:
	make
