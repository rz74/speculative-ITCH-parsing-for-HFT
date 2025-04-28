# =============================================
# reset_utils.py
# =============================================

# Description: Helper utilities to start clock and apply resets for cocotb testbenches.
# Author: RZ
# Start Date: 04172025
# Version: 0.1

# Changelog
# =============================================
# [20250427-1] RZ: Initial version for reset and clock helper functions.
# [20250428-1] RZ: Improved clock start function for flexibility and stability.
# =============================================

import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock

async def reset_dut(dut):
    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

async def start_clock(dut, period_ns=10):
    cocotb.start_soon(Clock(dut.clk, period_ns, units="ns").start())