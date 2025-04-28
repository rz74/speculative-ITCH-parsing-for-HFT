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
# [042720255] RZ: Added automatic timestamp-based VCD filenames for unique runs. Cleaned up compile vs simulation args separation
# =============================================
TOPLEVEL_LANG = verilog

VERILOG_SOURCES = ../rtl/payload_dispatcher.v ../rtl/add_order_decoder.v ../rtl/cancel_order_decoder.v ../synth/top.v
TOPLEVEL = top
MODULE = test_payload_parser
SIM = icarus

COMPILE_ARGS += -g2012 -DCOCOTB_SIM
EXTRA_ARGS ?=

include $(shell cocotb-config --makefiles)/Makefile.sim

# =============================================
# Utility: Get timestamp (MMDDYYYY_HHMMSS)
TIMESTAMP := $(shell date +%m%d%Y_%H%M%S)

# =============================================
# Targets
# =============================================

# Add Order tests
add_order:
	$(MAKE) COMPILE_ARGS="-g2012 -DCOCOTB_SIM -DDUMPFILE=\\\"add_order_dump_$(TIMESTAMP).vcd\\\"" MODULE=test_payload_parser
	mkdir -p vcd
	mv add_order_dump_$(TIMESTAMP).vcd vcd/add_order_dump_$(TIMESTAMP).vcd
	gtkwave vcd/add_order_dump_$(TIMESTAMP).vcd &

# Cancel Order tests
cancel_order:
	$(MAKE) COMPILE_ARGS="-g2012 -DCOCOTB_SIM -DDUMPFILE=\\\"cancel_order_dump_$(TIMESTAMP).vcd\\\"" MODULE=test_payload_parser
	mkdir -p vcd
	mv cancel_order_dump_$(TIMESTAMP).vcd vcd/cancel_order_dump_$(TIMESTAMP).vcd
	gtkwave vcd/cancel_order_dump_$(TIMESTAMP).vcd &

# Default run
default:
	$(MAKE) COMPILE_ARGS="-g2012 -DCOCOTB_SIM" MODULE=test_payload_parser
	mkdir -p vcd
	mv dump.vcd vcd/default_dump_$(TIMESTAMP).vcd
	gtkwave vcd/default_dump_$(TIMESTAMP).vcd &

# =============================================
# Cleanup Target
# =============================================

cleanall:
	find vcd/ -name "*.vcd" -type f -mtime +1 -delete
	rm -rf sim_build
	rm -f results.xml
	@echo "Cleaned sim build and VCD files older than 1 day."
