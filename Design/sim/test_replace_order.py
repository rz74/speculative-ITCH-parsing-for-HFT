# =============================================
# test_replace_order.py
# =============================================
#
# Description: Cocotb testbench for replace_order_decoder.v
# Author: RZ
# Start Date: 20250428
# Version: 0.2
#
# Changelog
# =============================================
# [20250428-1] RZ: Initial version for Replace Order testing
# [20250501-1] RZ: Initial implementation based on add_order_decoder testbench for new architecture
# =============================================

import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock
from helpers.payload_generator_helper import generate_replace_order_payload, generate_add_order_payload
from helpers.assertion_helper import assert_output_fields, assert_decode_pulse

@cocotb.test()
async def test_replace_order_basic(dut):
    """Test correct decoding of a valid Replace Order ('U') message"""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut._log.info("Starting Replace Order Decoder Test")

    # Reset
    dut.rst.value = 1
    dut.valid_in.value = 0
    dut.byte_in.value = 0
    for _ in range(3):
        await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Prepare a valid replace order
    payload = generate_replace_order_payload(index=17)
    assert len(payload) == 25, "Replace Order payload must be 25 bytes"

    for byte in payload:
        dut.byte_in.value = byte
        dut.valid_in.value = 1
        await RisingEdge(dut.clk)
    dut.valid_in.value = 0

    await assert_decode_pulse(dut, dut.replace_internal_valid, window=10)

    expected = {
        "replace_old_order_ref": int.from_bytes(payload[1:9], 'big'),
        "replace_new_order_ref": int.from_bytes(payload[9:17], 'big'),
        "replace_shares": int.from_bytes(payload[17:21], 'big'),
        "replace_price": int.from_bytes(payload[21:25], 'big'),
    }

    await assert_output_fields(dut, expected)
    dut._log.info("Replace Order Decoder test passed.")


@cocotb.test()
async def test_replace_decoder_ignores_non_replace(dut):
    """Decoder should ignore a valid Add Order ('A') message"""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut._log.info("Running negative test with Add Order packet")

    # Reset
    dut.rst.value = 1
    dut.valid_in.value = 0
    dut.byte_in.value = 0
    for _ in range(3):
        await RisingEdge(dut.clk)
    dut.rst.value = 0

    payload = generate_add_order_payload(index=5)
    for byte in payload:
        dut.byte_in.value = byte
        dut.valid_in.value = 1
        await RisingEdge(dut.clk)
    dut.valid_in.value = 0

    for _ in range(10):
        await RisingEdge(dut.clk)
        assert dut.replace_internal_valid.value == 0, "Replace decoder falsely triggered on non-Replace message"

    dut._log.info("Non-Replace message was correctly ignored.")
