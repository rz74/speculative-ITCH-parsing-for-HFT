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
# [20250504-1] RZ: Commented unused targets
# 
# =============================================
# =============================================
# Makefile  
# =============================================
# Description: Cocotb Makefile for ITCH Decoder Simulation
# Author: RZ
 
# =============================================
TOPLEVEL_LANG = verilog

VERILOG_SOURCES = \
    ../rtl/modules/add_order_decoder.v \
    ../rtl/modules/cancel_order_decoder.v \
    ../rtl/modules/delete_order_decoder.v \
    ../rtl/modules/replace_order_decoder.v \
    ../rtl/modules/executed_order_decoder.v \
    ../rtl/modules/trade_decoder.v \
    ../rtl/integrated.v

TOPLEVEL = integrated
SIM = icarus

# =============================================
# Simulation Options
COMPILE_ARGS += -g2012 -DCOCOTB_SIM -I../rtl
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
integrated: killwave
	@mkdir -p vcd
	TIMESTAMP=$$(date +%m%d%Y_%H%M%S); \
	$(MAKE) MODULE=test_integrated TOPLEVEL=integrated COMPILE_ARGS="$(COMPILE_ARGS)"; \
	mv dump.vcd vcd/integrated_dump_$${TIMESTAMP}.vcd; \
	gtkwave vcd/integrated_dump_$${TIMESTAMP}.vcd &

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

# add_order: killwave
# 	@mkdir -p vcd
# 	TIMESTAMP=$$(date +%m%d%Y_%H%M%S); \
# 	$(MAKE) MODULE=test_add_order TOPLEVEL=top_test COMPILE_ARGS="$(COMPILE_ARGS) -DTEST_ADD_ORDER_DECODER"; \
# 	mv dump.vcd vcd/add_order_dump_$${TIMESTAMP}.vcd; \
# 	gtkwave vcd/add_order_dump_$${TIMESTAMP}.vcd &

# cancel_order: killwave
# 	@mkdir -p vcd
# 	TIMESTAMP=$$(date +%m%d%Y_%H%M%S); \
# 	$(MAKE) MODULE=test_cancel_order TOPLEVEL=top_test COMPILE_ARGS="$(COMPILE_ARGS) -DTEST_CANCEL_ORDER_DECODER"; \
# 	mv dump.vcd vcd/cancel_order_dump_$${TIMESTAMP}.vcd; \
# 	gtkwave vcd/cancel_order_dump_$${TIMESTAMP}.vcd &

# delete_order: killwave
# 	@mkdir -p vcd
# 	TIMESTAMP=$$(date +%m%d%Y_%H%M%S); \
# 	$(MAKE) MODULE=test_delete_order TOPLEVEL=top_test COMPILE_ARGS="$(COMPILE_ARGS) -DTEST_DELETE_ORDER_DECODER"; \
# 	mv dump.vcd vcd/delete_order_dump_$${TIMESTAMP}.vcd; \
# 	gtkwave vcd/delete_order_dump_$${TIMESTAMP}.vcd &


# replace_order: killwave
# 	@mkdir -p vcd
# 	TIMESTAMP=$$(date +%m%d%Y_%H%M%S); \
# 	$(MAKE) MODULE=test_replace_order TOPLEVEL=top_test COMPILE_ARGS="$(COMPILE_ARGS) -DTEST_REPLACE_ORDER_DECODER"; \
# 	mv dump.vcd vcd/replace_order_dump_$${TIMESTAMP}.vcd; \
# 	gtkwave vcd/replace_order_dump_$${TIMESTAMP}.vcd &

# executed_order: killwave
# 	@mkdir -p vcd
# 	TIMESTAMP=$$(date +%m%d%Y_%H%M%S); \
# 	$(MAKE) MODULE=test_executed_order TOPLEVEL=top_test COMPILE_ARGS="$(COMPILE_ARGS) -DTEST_EXECUTED_ORDER_DECODER"; \
# 	mv dump.vcd vcd/executed_order_dump_$${TIMESTAMP}.vcd; \
# 	gtkwave vcd/executed_order_dump_$${TIMESTAMP}.vcd &

# trade: killwave
# 	@mkdir -p vcd
# 	TIMESTAMP=$$(date +%m%d%Y_%H%M%S); \
# 	$(MAKE) MODULE=test_trade TOPLEVEL=top_test COMPILE_ARGS="$(COMPILE_ARGS) -DTEST_TRADE_DECODER"; \
# 	mv dump.vcd vcd/trade_dump_$${TIMESTAMP}.vcd; \
# 	gtkwave vcd/trade_dump_$${TIMESTAMP}.vcd &

# watchdog: killwave
# 	@mkdir -p vcd
# 	TIMESTAMP=$$(date +%m%d%Y_%H%M%S); \
# 	$(MAKE) MODULE=test_decoder_watchdog TOPLEVEL=decoder_watchdog COMPILE_ARGS="$(COMPILE_ARGS)"; \
# 	mv dump.vcd vcd/watchdog_dump_$${TIMESTAMP}.vcd; \
# 	gtkwave vcd/watchdog_dump_$${TIMESTAMP}.vcd &


# itch_parser: killwave
# 	@mkdir -p vcd
# 	TIMESTAMP=$$(date +%m%d%Y_%H%M%S); \
# 	$(MAKE) MODULE=test_itch_parser TOPLEVEL=itch_parser COMPILE_ARGS="$(COMPILE_ARGS) -DTEST_ITCH_PARSER"; \
# 	mv dump.vcd vcd/itch_parser_dump_$${TIMESTAMP}.vcd; \
# 	gtkwave vcd/itch_parser_dump_$${TIMESTAMP}.vcd &


