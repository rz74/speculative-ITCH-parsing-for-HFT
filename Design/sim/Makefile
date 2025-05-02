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
# [20250501-1] RZ: Removed obsolete header_parser.v from the list of sources.
# [20250501-2] RZ: Added executed_order module and testbench.
# [20250501-3] RZ: Added trade module and testbench.
# 
# =============================================
# =============================================
# Makefile (Patched)
# =============================================
# Description: Cocotb Makefile for ITCH Decoder Simulation
# Author: RZ
# Updated: 2025-04-30 — removed obsolete header_parser.v
# =============================================

# =============================================
# Makefile (Final Patched)
# =============================================

TOPLEVEL_LANG = verilog

VERILOG_SOURCES = \
    ../sim/top_test.v \
    ../rtl/add_order_decoder.v \
    ../rtl/cancel_order_decoder.v \
    ../rtl/delete_order_decoder.v \
    ../rtl/replace_order_decoder.v \
	../rtl/executed_order_decoder.v \
	../rtl/trade_decoder.v

TOPLEVEL = top_test
SIM = icarus

COMPILE_ARGS += -g2012 -DCOCOTB_SIM
EXTRA_ARGS ?=

include $(shell cocotb-config --makefiles)/Makefile.sim

# =============================================
# Utility: Kill GTKWave if running
# =============================================
killwave:
	@pkill gtkwave || true

# =============================================
# Simulation Targets
# =============================================

add_order: killwave
	@mkdir -p vcd
	TIMESTAMP=$$(date +%m%d%Y_%H%M%S); \
	$(MAKE) MODULE=test_add_order TOPLEVEL=top_test COMPILE_ARGS="$(COMPILE_ARGS) -DTEST_ADD_ORDER_DECODER"; \
	mv dump.vcd vcd/add_order_dump_$${TIMESTAMP}.vcd; \
	gtkwave vcd/add_order_dump_$${TIMESTAMP}.vcd &

cancel_order: killwave
	@mkdir -p vcd
	TIMESTAMP=$$(date +%m%d%Y_%H%M%S); \
	$(MAKE) MODULE=test_cancel_order TOPLEVEL=top_test COMPILE_ARGS="$(COMPILE_ARGS) -DTEST_CANCEL_ORDER_DECODER"; \
	mv dump.vcd vcd/cancel_order_dump_$${TIMESTAMP}.vcd; \
	gtkwave vcd/cancel_order_dump_$${TIMESTAMP}.vcd &

delete_order: killwave
	@mkdir -p vcd
	TIMESTAMP=$$(date +%m%d%Y_%H%M%S); \
	$(MAKE) MODULE=test_delete_order TOPLEVEL=top_test COMPILE_ARGS="$(COMPILE_ARGS) -DTEST_DELETE_ORDER_DECODER"; \
	mv dump.vcd vcd/delete_order_dump_$${TIMESTAMP}.vcd; \
	gtkwave vcd/delete_order_dump_$${TIMESTAMP}.vcd &


replace_order: killwave
	@mkdir -p vcd
	TIMESTAMP=$$(date +%m%d%Y_%H%M%S); \
	$(MAKE) MODULE=test_replace_order TOPLEVEL=top_test COMPILE_ARGS="$(COMPILE_ARGS) -DTEST_REPLACE_ORDER_DECODER"; \
	mv dump.vcd vcd/replace_order_dump_$${TIMESTAMP}.vcd; \
	gtkwave vcd/replace_order_dump_$${TIMESTAMP}.vcd &

executed_order: killwave
	@mkdir -p vcd
	TIMESTAMP=$$(date +%m%d%Y_%H%M%S); \
	$(MAKE) MODULE=test_executed_order TOPLEVEL=top_test COMPILE_ARGS="$(COMPILE_ARGS) -DTEST_EXECUTED_ORDER_DECODER"; \
	mv dump.vcd vcd/executed_order_dump_$${TIMESTAMP}.vcd; \
	gtkwave vcd/executed_order_dump_$${TIMESTAMP}.vcd &

trade: killwave
	@mkdir -p vcd
	TIMESTAMP=$$(date +%m%d%Y_%H%M%S); \
	$(MAKE) MODULE=test_trade TOPLEVEL=top_test COMPILE_ARGS="$(COMPILE_ARGS) -DTEST_TRADE_DECODER"; \
	mv dump.vcd vcd/trade_dump_$${TIMESTAMP}.vcd; \
	gtkwave vcd/trade_dump_$${TIMESTAMP}.vcd &




default: killwave
	@mkdir -p vcd
	TIMESTAMP=$$(date +%m%d%Y_%H%M%S); \
	$(MAKE) MODULE=test_payload_parser COMPILE_ARGS="$(COMPILE_ARGS) -DTEST_FULL_SYSTEM"; \
	mv dump.vcd vcd/full_test_dump_$${TIMESTAMP}.vcd; \
	gtkwave vcd/full_test_dump_$${TIMESTAMP}.vcd &

# =============================================
# Cleanup
# =============================================

cleanall:
	find vcd/ -name "*.vcd" -type f -mtime +1 -delete
	rm -rf sim_build
	rm -f results.xml
	@echo "Cleaned sim build and old VCD files."

view_latest:
	gtkwave $$(ls -t vcd/*.vcd | head -n1) &
