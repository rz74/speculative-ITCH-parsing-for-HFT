# =============================================
# reset_helper.py
# =============================================

# Description: Clock and reset utilities for cocotb-based verification.
# Author: RZ
# Start Date: 04172025
# Version: 0.3

# Changelog
# =============================================
# [20250427-1] RZ: Initial version (see reset_utils.py).
# [20250428-1] RZ: Added reset_and_test_decoder_behavior for decoder scenarios.
# [20250429-1] RZ: Adopted into new reset_helper.py from reset_utils.py.
# [20250429-2] RZ: Added reset_midstream utility for recovery tests.
# =============================================

import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock

async def start_clock(dut, period_ns=10):
    cocotb.start_soon(Clock(dut.clk, period_ns, units="ns").start())

async def reset_dut(dut, duration_clks=2):
    dut.rst_n.value = 0
    for _ in range(duration_clks):
        await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

async def reset_midstream(dut, trigger_cycle=2):
    dut.rst_n.value = 1
    for cycle in range(trigger_cycle):
        await RisingEdge(dut.clk)
    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
