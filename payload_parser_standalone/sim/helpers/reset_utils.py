# =============================================
# reset_utils.py
# =============================================

# Description: Helper utilities to start clock and apply resets for cocotb testbenches.
# Author: RZ
# Start Date: 04172025
# Version: 0.1

# Changelog
# =============================================
# =============================================
# Reset Utilities
# =============================================
# Includes:
# - start_clock
# - reset_dut
# - reset_and_test_decoder_behavior
# =============================================

# [20250427-1] RZ: Initial version for reset and clock helper functions.
# [20250428-1] RZ: Improved clock start function for flexibility and stability.
# [20250501-1] RZ: Added reset_and_test_decoder_behavior function for decoder testing.
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



async def reset_and_test_decoder_behavior(dut, payload_generator, decoded_signal, expect_decode_after_reset):
    """
    Reset DUT, inject payload, and verify decoder behavior based on expectation.

    Args:
        dut: Device Under Test
        payload_generator: Function that returns a payload (valid or dummy)
        decoded_signal: Signal to monitor (e.g., add_order_decoded)
        expect_decode_after_reset: True if expecting decoding, False if expecting no decoding
    """
    payload = payload_generator(0)

    # Apply reset
    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    # Inject payload
    dut.in_valid.value = 1
    dut.msg_type.value = payload[0]
    dut.payload.value = int.from_bytes(payload.ljust(64, b'\x00'), byteorder='big')
    await RisingEdge(dut.clk)
    dut.in_valid.value = 0
    await RisingEdge(dut.clk)

    if expect_decode_after_reset:
        assert decoded_signal.value == 1, "Expected decode after reset, but decode did not happen!"
        cocotb.log.info("✅ Decoder correctly fired after reset with valid payload.")
    else:
        assert decoded_signal.value == 0, "Unexpected decode after reset with dummy payload!"
        cocotb.log.info("✅ Decoder correctly idle after reset with dummy payload.")
