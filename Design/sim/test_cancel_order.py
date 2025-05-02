# =============================================
# test_cancel_order_only.py
# =============================================

# Description: Cocotb testbench for validating Cancel Order ('X') decoding only.
# Author: RZ
# Start Date: 04172025
# Version: 0.1

# Changelog
# =============================================
# [20250427-1] RZ: Initial version created for Cancel Order only testing.
# [20250428-1] RZ: Integrated with modular payload_parser project structure.
# [20250428-2] RZ: Removed incomplete payload testing from module-level testbench for clean modularity.
# [20250428-3] RZ: Added valid flag log
# =============================================

# // =============================================

# // architecture update and name update

# // =============================================

# =============================================
# test_cancel_order.py
# =============================================
#
# Description: Cocotb testbench for cancel_order_decoder.v
# Author: RZ
# Start Date: 20250501
# Version: 0.1
#
# Changelog
# =============================================
# [20250501-1] RZ: Initial version with basic and negative test coverage under new architecture.



import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock
from helpers.payload_generator_helper import generate_cancel_order_payload, generate_add_order_payload
from helpers.assertion_helper import assert_output_fields, assert_decode_pulse

@cocotb.test()
async def test_cancel_order_basic(dut):
    """Test correct decoding of a valid Cancel Order ('X') message"""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut._log.info("Starting Cancel Order Decoder Test")

    # Reset
    dut.rst.value = 1
    dut.valid_in.value = 0
    dut.byte_in.value = 0
    for _ in range(3):
        await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Prepare and send a valid cancel order
    payload = generate_cancel_order_payload(index=42)
    assert len(payload) == 23, "Cancel Order payload must be 23 bytes"

    for byte in payload:
        dut.byte_in.value = byte
        dut.valid_in.value = 1
        await RisingEdge(dut.clk)
    dut.valid_in.value = 0

    # Wait and verify
    await assert_decode_pulse(dut, dut.cancel_internal_valid, window=10)

    expected = {
        "cancel_order_ref": int.from_bytes(payload[1:9], 'big'),
        "cancel_canceled_shares": int.from_bytes(payload[9:13], 'big'),
    }

    await assert_output_fields(dut, expected)

    dut._log.info("Cancel Order Decoder test passed.")


@cocotb.test()
async def test_cancel_decoder_ignores_non_cancel(dut):
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

    # Send an Add Order packet (should be ignored by cancel decoder)
    payload = generate_add_order_payload(index=3)
    for byte in payload:
        dut.byte_in.value = byte
        dut.valid_in.value = 1
        await RisingEdge(dut.clk)
    dut.valid_in.value = 0

    # Watch internal_valid — should never trigger
    for _ in range(10):
        await RisingEdge(dut.clk)
        assert dut.cancel_internal_valid.value == 0, "Cancel decoder falsely triggered on non-Cancel message"

    dut._log.info("Non-Cancel message correctly ignored.")

