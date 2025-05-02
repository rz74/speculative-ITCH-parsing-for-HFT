# =============================================
# test_trade.py
# =============================================
#
# Description: Cocotb testbench for trade_decoder.v
# Author: RZ
# Start Date: 20250501
# Version: 0.1
#
# Changelog
# =============================================
# [20250501-1] RZ: Initial implementation with full trade field coverage
# =============================================

import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock
from helpers.payload_generator_helper import generate_trade_payload, generate_add_order_payload
from helpers.assertion_helper import assert_output_fields, assert_decode_pulse

@cocotb.test()
async def test_trade_basic(dut):
    """Test correct decoding of a valid Trade ('P') message"""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut._log.info("Starting Trade Decoder Test")

    # Reset
    dut.rst.value = 1
    dut.valid_in.value = 0
    dut.byte_in.value = 0
    for _ in range(3):
        await RisingEdge(dut.clk)
    dut.rst.value = 0

    payload = generate_trade_payload(index=88)
    assert len(payload) == 44, "Trade payload must be 44 bytes"

    for byte in payload:
        dut.byte_in.value = byte
        dut.valid_in.value = 1
        await RisingEdge(dut.clk)
    dut.valid_in.value = 0

    await assert_decode_pulse(dut, dut.trade_internal_valid, window=10)

    expected = {
        "trade_order_ref": int.from_bytes(payload[1:9], 'big'),
        "trade_shares": int.from_bytes(payload[9:13], 'big'),
        "trade_match_id": int.from_bytes(payload[13:21], 'big'),
        "trade_stock_symbol": int.from_bytes(payload[21:29], 'big'),
        "trade_price": int.from_bytes(payload[29:33], 'big'),
        "trade_timestamp": int.from_bytes(payload[33:37], 'big'),
    }

    await assert_output_fields(dut, expected)
    dut._log.info("Trade Decoder test passed.")


@cocotb.test()
async def test_trade_decoder_ignores_non_trade(dut):
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

    payload = generate_add_order_payload(index=999)
    for byte in payload:
        dut.byte_in.value = byte
        dut.valid_in.value = 1
        await RisingEdge(dut.clk)
    dut.valid_in.value = 0

    for _ in range(10):
        await RisingEdge(dut.clk)
        assert dut.trade_internal_valid.value == 0, "Trade decoder falsely triggered on non-Trade message"

    dut._log.info("Non-Trade message was correctly ignored.")
