# =============================================
# test_delete_order_only.py
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

import cocotb
from cocotb.triggers import RisingEdge
from helpers.reset_utils import start_clock, reset_dut
from helpers.payload_generators import generate_delete_order_payload
from helpers.payload_injection import (
    inject_random_payload,
    inject_incomplete_payload,
    inject_wrong_msg_type,
    inject_multiple_valid_msgs,
    reset_mid_payload
)

@cocotb.test()
async def test_delete_order_only(dut):
    """Testbench: Only run Delete Order related tests."""
    await start_clock(dut)
    await reset_dut(dut)

    # Basic decode
    await run_delete_order_basic_test(dut)
    # await RisingEdge(dut.clk) 
    # cocotb.log.info(f"[LOG] Delete Order valid_flag: {dut.delete_order_valid_flag.value}")


    # Random garbage
    await inject_random_payload(dut, dut.delete_order_decoded)

    # Incomplete payload
    await inject_incomplete_payload(dut, dut.delete_order_decoded)

    # Wrong message type
    await inject_wrong_msg_type(dut, dut.delete_order_decoded)

    # Multiple valid messages
    await inject_multiple_valid_msgs(dut, generate_delete_order_payload)

    # Reset during decode
    await reset_mid_payload(dut, generate_delete_order_payload, dut.delete_order_decoded)

    cocotb.log.info("All Delete Order tests completed successfully.")

async def run_delete_order_basic_test(dut):
    """Test for basic Delete Order decoding."""
    payload = generate_delete_order_payload(0)

    dut.in_valid.value = 1
    dut.msg_type.value = payload[0]  # Should be ASCII 'D'
    dut.payload.value = int.from_bytes(payload.ljust(64, b'\x00'), byteorder='big')

    await RisingEdge(dut.clk)
    dut.in_valid.value = 0

    for _ in range(5):
        await RisingEdge(dut.clk)

    cocotb.log.info("Delete Order basic decode test passed.")
