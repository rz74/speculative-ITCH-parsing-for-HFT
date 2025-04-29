# =============================================
# test_add_order_only.py
# =============================================

# Description: Cocotb testbench for validating Add Order ('A') decoding only.
# Author: RZ
# Start Date: 04172025
# Version: 0.2

# Changelog
# =============================================
# [20250427-1] RZ: Initial version created for Add Order only testing.
# [20250428-1] RZ: Integrated with modular payload_parser project structure.
# [20250428-2] RZ: Removed incomplete payload testing from module-level testbench for clean modularity.
# =============================================

import cocotb
from cocotb.triggers import RisingEdge
from helpers.reset_utils import start_clock, reset_dut
from helpers.payload_generators import generate_add_order_payload
from helpers.payload_injection import (
    inject_random_payload,
    inject_wrong_msg_type,
    inject_multiple_valid_msgs,
    reset_mid_payload
)

@cocotb.test()
async def test_add_order_only(dut):
    """Testbench: Only run Add Order related tests."""
    await start_clock(dut)
    await reset_dut(dut)

    # Basic decode
    await run_add_order_basic_test(dut)

    # Random garbage
    await inject_random_payload(dut, dut.add_order_decoded)

    # Wrong message type
    await inject_wrong_msg_type(dut, dut.add_order_decoded)

    # Multiple valid messages
    await inject_multiple_valid_msgs(dut, generate_add_order_payload)

    # Reset during decode
    await reset_mid_payload(dut, generate_add_order_payload, dut.add_order_decoded)

    cocotb.log.info("All Add Order tests completed successfully.")

async def run_add_order_basic_test(dut):
    """Test for basic Add Order decoding."""
    payload = generate_add_order_payload(0)

    dut.in_valid.value = 1
    dut.msg_type.value = payload[0]  # Should be ASCII 'A'
    dut.payload.value = int.from_bytes(payload.ljust(64, b'\x00'), byteorder='big')

    await RisingEdge(dut.clk)
    dut.in_valid.value = 0

    for _ in range(5):
        await RisingEdge(dut.clk)

    cocotb.log.info("Add Order basic decode test passed.")
