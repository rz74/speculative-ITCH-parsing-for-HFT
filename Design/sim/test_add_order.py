# =============================================
# test_add_order_only.py
# =============================================

# Description: Cocotb testbench for validating Add Order ('A') decoder in speculative pipeline.
# Author: RZ
# Start Date: 04172025
# Version: 0.4

# Changelog
# =============================================
# [20250427-1] RZ: Initial version created for Add Order only testing.
# [20250428-1] RZ: Modularized with project structure.
# [20250429-1] RZ: Refactored to use top_test.v and unified helper structure.
# [20250429-2] RZ: Updated to use inject_and_expect_decode from injection_helper.
# =============================================
# // =============================================

# // architecture update

# // =============================================
# =============================================
# test_add_order_decoder.py
# =============================================
#
# Description: Cocotb testbench for add_order_decoder.v
# Author: RZ
# Start Date: 20250430
# Version: 0.1
#
# Changelog
# =============================================
# [20250430-1] RZ: Initial version using helpers and top_test.v integration
# [20250430-2] RZ: Initial version using helpers and top_test.v integration
# [20250501-1] RZ: Aligned expected fields with official ITCH format.
# =============================================

import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock
from helpers.payload_generator_helper import generate_add_order_payload, generate_cancel_order_payload
from helpers.assertion_helper import assert_output_fields, assert_decode_pulse

@cocotb.test()
async def test_add_order_basic(dut):
    """Test correct decoding of a valid Add Order ('A') message"""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut._log.info("Starting Add Order Decoder Test")

    # Reset
    dut.rst.value = 1
    dut.valid_in.value = 0
    dut.byte_in.value = 0
    for _ in range(3):
        await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Prepare payload
    payload = generate_add_order_payload(index=1)
    assert len(payload) == 36, "Payload must be 36 bytes"

    # Drive input stream
    for byte in payload:
        dut.byte_in.value = byte
        dut.valid_in.value = 1
        await RisingEdge(dut.clk)
    dut.valid_in.value = 0

    # Wait and check for internal_valid
    await assert_decode_pulse(dut, dut.add_internal_valid, window=10)

    expected = {
        "add_order_ref": int.from_bytes(payload[1:9], 'big'),
        "add_side": int(payload[9] == ord("S")),
        "add_shares": int.from_bytes(payload[10:14], 'big'),
        "add_stock_symbol": int.from_bytes(payload[14:22], 'big'),
        "add_price": int.from_bytes(payload[22:26], 'big'),
    }

    await assert_output_fields(dut, expected)

    dut._log.info("Add Order Decoder test passed.")

@cocotb.test()
async def test_add_decoder_ignores_non_add(dut):
    """Decoder should ignore a valid Cancel Order ('X') message"""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut._log.info("Running negative test with Cancel Order packet")

    # Reset
    dut.rst.value = 1
    dut.valid_in.value = 0
    dut.byte_in.value = 0
    for _ in range(3):
        await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Step 1: Send a Cancel Order (non-'A') payload
    payload = generate_cancel_order_payload(index=1)
    for byte in payload:
        dut.byte_in.value = byte
        dut.valid_in.value = 1
        await RisingEdge(dut.clk)
    dut.valid_in.value = 0

    # Step 2: Wait and check that internal_valid is never asserted
    for _ in range(10):
        await RisingEdge(dut.clk)
        assert dut.add_internal_valid.value == 0, "Decoder incorrectly triggered on non-Add message"

    dut._log.info("Non-Add message was correctly ignored.")

