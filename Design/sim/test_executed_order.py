# =============================================
# test_executed_order.py
# =============================================
#
# Description: Cocotb testbench for executed_order_decoder.v
# Author: RZ
# Start Date: 20250501
# Version: 0.1
#
# Changelog
# =============================================
# [20250501-1] RZ: Initial testbench for Executed Order decoder
# =============================================

import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock
from helpers.payload_generator_helper import generate_executed_order_payload, generate_add_order_payload
from helpers.assertion_helper import assert_output_fields, assert_decode_pulse

@cocotb.test()
async def test_executed_order_basic(dut):
    """Test correct decoding of a valid Executed Order ('E') message"""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut._log.info("Starting Executed Order Decoder Test")

    # Reset
    dut.rst.value = 1
    dut.valid_in.value = 0
    dut.byte_in.value = 0
    for _ in range(3):
        await RisingEdge(dut.clk)
    dut.rst.value = 0

    payload = generate_executed_order_payload(index=8)
    assert len(payload) == 31, "Executed Order payload must be 31 bytes"

    for byte in payload:
        dut.byte_in.value = byte
        dut.valid_in.value = 1
        await RisingEdge(dut.clk)
    dut.valid_in.value = 0

    await assert_decode_pulse(dut, dut.exec_internal_valid, window=10)

    expected = {
        "exec_order_ref": int.from_bytes(payload[1:9], 'big'),
        "exec_shares": int.from_bytes(payload[9:13], 'big'),
        "exec_match_id": int.from_bytes(payload[13:21], 'big'),
        "exec_timestamp": int.from_bytes(payload[21:25], 'big'),
    }

    await assert_output_fields(dut, expected)
    dut._log.info("Executed Order Decoder test passed.")


@cocotb.test()
async def test_exec_decoder_ignores_non_exec(dut):
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

    payload = generate_add_order_payload(index=6)
    for byte in payload:
        dut.byte_in.value = byte
        dut.valid_in.value = 1
        await RisingEdge(dut.clk)
    dut.valid_in.value = 0

    for _ in range(10):
        await RisingEdge(dut.clk)
        assert dut.exec_internal_valid.value == 0, "Executed decoder falsely triggered on non-Executed message"

    dut._log.info("Non-Executed message was correctly ignored.")
