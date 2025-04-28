# =============================================
# Makefile
# =============================================

# Makefile for cocotb simulation of the payload_parser module
# Author: RZ
# Start Date: 04172025

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
# [042720255] RZ: Added automatic timestamp-based VCD filenames for unique runs. Cleaned up compile vs simulation args separation
# [04282025] RZ:
# - Added dynamic timestamp generation per target (no overwrite)
# - Added view_latest to quickly open latest VCD file in GTKWave
# =============================================

TOPLEVEL_LANG = verilog

VERILOG_SOURCES = ../rtl/payload_dispatcher.v ../rtl/add_order_decoder.v ../rtl/cancel_order_decoder.v ../synth/top.v
TOPLEVEL = top
SIM = icarus

COMPILE_ARGS += -g2012 -DCOCOTB_SIM
EXTRA_ARGS ?=

include $(shell cocotb-config --makefiles)/Makefile.sim

# Kill any old GTKWave windows
killwave:
	@pkill gtkwave || true

# =============================================
# Simulation Targets
# =============================================

add_order: killwave
	$(MAKE) COMPILE_ARGS="-g2012 -DCOCOTB_SIM" MODULE=test_add_order_only
	mkdir -p vcd
	TIMESTAMP=$$(date +%m%d%Y_%H%M%S); \
	mv dump.vcd vcd/add_order_dump_$${TIMESTAMP}.vcd; \
	gtkwave vcd/add_order_dump_$${TIMESTAMP}.vcd &

cancel_order: killwave
	$(MAKE) COMPILE_ARGS="-g2012 -DCOCOTB_SIM" MODULE=test_cancel_order_only
	mkdir -p vcd
	TIMESTAMP=$$(date +%m%d%Y_%H%M%S); \
	mv dump.vcd vcd/cancel_order_dump_$${TIMESTAMP}.vcd; \
	gtkwave vcd/cancel_order_dump_$${TIMESTAMP}.vcd &

default: killwave
	$(MAKE) COMPILE_ARGS="-g2012 -DCOCOTB_SIM" MODULE=test_payload_parser
	mkdir -p vcd
	TIMESTAMP=$$(date +%m%d%Y_%H%M%S); \
	mv dump.vcd vcd/full_test_dump_$${TIMESTAMP}.vcd; \
	gtkwave vcd/full_test_dump_$${TIMESTAMP}.vcd &

# =============================================
# Utility Targets
# =============================================

cleanall:
	find vcd/ -name "*.vcd" -type f -mtime +1 -delete
	rm -rf sim_build
	rm -f results.xml
	@echo "Cleaned sim build and old VCD files."


# View the most recent VCD
view_latest:
	gtkwave $$(ls -t vcd/*.vcd | head -n1) &