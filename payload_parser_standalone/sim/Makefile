# =============================================
# Makefile
# =============================================


# Makefile for cocotb simulation of the payload_parser module

# Changelog
# =============================================
# [04272025] RZ:
# - Initial version of multi-target Makefile
# - Added support for DUMPFILE macro
# - Separate targets for add_order and cancel_order simulation
# - Default VCD dump fallback
# [042720252] RZ: Added auto-move of VCD files into vcd/ folder after simulation
# [042720253] RZ: Added clean target to remove old build and VCD files
# [042720254] RZ: Added support for GTKWave to open VCD files after simulation
# =============================================

TOPLEVEL_LANG = verilog

VERILOG_SOURCES = ../rtl/payload_dispatcher.v ../rtl/add_order_decoder.v ../rtl/cancel_order_decoder.v ../synth/top.v
TOPLEVEL = top
MODULE = test_payload_parser
SIM = icarus

COMPILE_ARGS += -g2012 -DCOCOTB_SIM
EXTRA_ARGS ?=

# Include cocotb makefile
include $(shell cocotb-config --makefiles)/Makefile.sim

# Hook: after running the simulation
SIM_BUILD_POST_CMD = mkdir -p vcd && mv *.vcd vcd/

# =============================================
# Targets
# =============================================
# Add Order tests
add_order:
	$(MAKE) EXTRA_ARGS="-DDUMPFILE=\\\"add_order_dump.vcd\\\"" MODULE=test_payload_parser
	mv add_order_dump.vcd vcd/add_order_dump.vcd
	gtkwave vcd/add_order_dump.vcd &

# Cancel Order tests
cancel_order:
	$(MAKE) EXTRA_ARGS="-DDUMPFILE=\\\"cancel_order_dump.vcd\\\"" MODULE=test_payload_parser
	mv cancel_order_dump.vcd vcd/cancel_order_dump.vcd
	gtkwave vcd/cancel_order_dump.vcd &

# Default (full run)
default:
	$(MAKE) EXTRA_ARGS="" MODULE=test_payload_parser
	mv default_dump.vcd vcd/default_dump.vcd
	gtkwave vcd/default_dump.vcd &


# =============================================
# Cleanup targets
# =============================================

cleanall:
	rm -rf sim_build
	rm -rf results.xml
	rm -rf vcd/*.vcd
	@echo "Cleaned old build and VCD files."

