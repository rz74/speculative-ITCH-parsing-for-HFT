# =============================================
# test_delete_order.py
# =============================================

# Description: Cocotb testbench for validating Delete Order ('D') decoding only.
# Author: RZ
# Start Date: 04172025
# Version: 0.1

# Changelog
# =============================================
# [20250428-1] RZ: Initial version created for Delete Order only testing.
# [20250428-2] RZ: Integrated with modular payload_parser project structure.
# [20250428-3] RZ: Removed incomplete payload testing from module-level testbench for clean modularity.
# [20250428-4] RZ: Added valid flag log 
# =============================================
# =============================================
# test_delete_order.py
# =============================================
#
# Description: Cocotb testbench for delete_order_decoder.v
# Author: RZ
# Start Date: 20250501
# Version: 0.1
#
# Changelog
# =============================================
# [20250501-1] RZ: Initial testbench for Delete Order decoder.
# [20250501-2] RZ: updated under new architecture 
# =============================================

import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock
from helpers.payload_generator_helper import generate_delete_order_payload, generate_add_order_payload
from helpers.assertion_helper import assert_output_fields, assert_decode_pulse

@cocotb.test()
async def test_delete_order_basic(dut):
    """Test correct decoding of a valid Delete Order ('D') message"""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut._log.info("Starting Delete Order Decoder Test")

    # Reset
    dut.rst.value = 1
    dut.valid_in.value = 0
    dut.byte_in.value = 0
    for _ in range(3):
        await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Prepare and send a valid delete order
    payload = generate_delete_order_payload(index=7)
    assert len(payload) == 9, "Delete Order payload must be 9 bytes"

    for byte in payload:
        dut.byte_in.value = byte
        dut.valid_in.value = 1
        await RisingEdge(dut.clk)
    dut.valid_in.value = 0

    await assert_decode_pulse(dut, dut.delete_internal_valid, window=10)

    expected = {
        "delete_order_ref": int.from_bytes(payload[1:9], 'big'),
    }

    await assert_output_fields(dut, expected)
    dut._log.info("Delete Order Decoder test passed.")


@cocotb.test()
async def test_delete_decoder_ignores_non_delete(dut):
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

    # Send an Add Order packet (should be ignored by delete decoder)
    payload = generate_add_order_payload(index=3)
    for byte in payload:
        dut.byte_in.value = byte
        dut.valid_in.value = 1
        await RisingEdge(dut.clk)
    dut.valid_in.value = 0

    for _ in range(10):
        await RisingEdge(dut.clk)
        assert dut.delete_internal_valid.value == 0, "Delete decoder falsely triggered on non-Delete message"

    dut._log.info("Non-Delete message correctly ignored.")

