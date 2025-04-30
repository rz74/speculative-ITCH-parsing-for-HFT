# =============================================
# Makefile
# =============================================

# Description: Makefile for cocotb simulation, VCD handling, and GTKWave automation.
# Author: RZ
# Start Date: 04172025
# Version: 0.3

# Changelog
# =============================================
# [20250427-1] RZ: Initial version of multi-target Makefile for payload_parser simulation.
# [20250427-2] RZ: Added auto-move of VCD files into vcd/ folder after simulation.
# [20250427-3] RZ: Added cleanall target to remove old builds and VCDs.
# [20250427-4] RZ: Added GTKWave auto-open after simulation.
# [20250428-1] RZ: Added dynamic timestamp-based VCD renaming after simulation.
# [20250428-2] RZ: Added killwave functionality to close old GTKWave windows before new simulation.
# [20250428-3] RZ: Added del module
# [20250429-1] RZ: Added replace module
# [20250429-2] RZ: Added header_parser module with top_test.v support
# [20250429-3] RZ: Migrated all module testbenches to use top_test.v by default
# =============================================

TOPLEVEL_LANG = verilog

VERILOG_SOURCES = \
    ../rtl/header_parser.v \
    ../sim/top_test.v \
    ../rtl/payload_dispatcher.v \
    ../rtl/add_order_decoder.v \
    ../rtl/cancel_order_decoder.v \
    ../rtl/delete_order_decoder.v \
    ../rtl/replace_order_decoder.v \
    ../rtl/length_validator.v

TOPLEVEL = top_test
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
	$(MAKE) COMPILE_ARGS="-g2012 -DCOCOTB_SIM -DTEST_ADD_ORDER_DECODER" MODULE=test_add_order_only TOPLEVEL=top_test
	mkdir -p vcd
	TIMESTAMP=$$(date +%m%d%Y_%H%M%S); \
	mv dump.vcd vcd/add_order_dump_$${TIMESTAMP}.vcd; \
	gtkwave vcd/add_order_dump_$${TIMESTAMP}.vcd &


cancel_order: killwave
	$(MAKE) COMPILE_ARGS="-g2012 -DCOCOTB_SIM -DTEST_CANCEL_ORDER" MODULE=test_cancel_order_only
	mkdir -p vcd
	TIMESTAMP=$$(date +%m%d%Y_%H%M%S); \
	mv dump.vcd vcd/cancel_order_dump_$${TIMESTAMP}.vcd; \
	gtkwave vcd/cancel_order_dump_$${TIMESTAMP}.vcd &

delete_order: killwave
	$(MAKE) COMPILE_ARGS="-g2012 -DCOCOTB_SIM -DTEST_DELETE_ORDER" MODULE=test_delete_order_only
	mkdir -p vcd
	TIMESTAMP=$$(date +%Y%m%d_%H%M%S); \
	mv dump.vcd vcd/delete_order_dump_$${TIMESTAMP}.vcd; \
	gtkwave vcd/delete_order_dump_$${TIMESTAMP}.vcd &

replace_order: killwave
	$(MAKE) COMPILE_ARGS="-g2012 -DCOCOTB_SIM -DTEST_REPLACE_ORDER" MODULE=test_replace_order_only
	mkdir -p vcd
	TIMESTAMP=$$(date +%Y%m%d_%H%M%S); \
	mv dump.vcd vcd/replace_order_dump_$${TIMESTAMP}.vcd; \
	gtkwave vcd/replace_order_dump_$${TIMESTAMP}.vcd &

header_parser: killwave
	$(MAKE) COMPILE_ARGS="-g2012 -DCOCOTB_SIM -DTEST_HEADER_PARSER" MODULE=test_header_parser
	mkdir -p vcd
	TIMESTAMP=$$(date +%Y%m%d_%H%M%S); \
	mv dump.vcd vcd/header_parser_dump_$${TIMESTAMP}.vcd; \
	gtkwave vcd/header_parser_dump_$${TIMESTAMP}.vcd &

default: killwave
	$(MAKE) COMPILE_ARGS="-g2012 -DCOCOTB_SIM -DTEST_FULL_SYSTEM" MODULE=test_payload_parser
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
