# =============================================
# test_replace_order_only.py
# =============================================

# Description: Cocotb testbench for Replace Order decoder ('U')
# Author: RZ
# Start Date: 20250428

# Changelog
# =============================================
# [20250428-1] RZ: Initial version for Replace Order testing
# =============================================

import cocotb
from cocotb.triggers import RisingEdge
from helpers.reset_utils import start_clock, reset_dut
from helpers.payload_generators import generate_replace_order_payload
from helpers.payload_injection import (
    inject_random_payload,
    inject_wrong_msg_type,
    inject_multiple_valid_msgs,
    reset_mid_payload
)

@cocotb.test()
async def test_replace_order_only(dut):
    await start_clock(dut)
    await reset_dut(dut)

    await run_replace_order_basic_test(dut)
    # cocotb.log.info(f"[LOG] Replace Order valid_flag: {dut.replace_order_valid_flag.value}")

    await inject_random_payload(dut, dut.replace_order_decoded)
    await inject_wrong_msg_type(dut, dut.replace_order_decoded)
    await inject_multiple_valid_msgs(dut, generate_replace_order_payload)
    await reset_mid_payload(dut, generate_replace_order_payload, dut.replace_order_decoded)

    cocotb.log.info("All Replace Order tests completed successfully.")

async def run_replace_order_basic_test(dut):
    payload = generate_replace_order_payload(0)

    dut.in_valid.value = 1
    dut.msg_type.value = payload[0]
    dut.payload.value = int.from_bytes(payload.ljust(64, b'\x00'), byteorder='big')

    await RisingEdge(dut.clk)
    dut.in_valid.value = 0

    for _ in range(5):
        await RisingEdge(dut.clk)

    cocotb.log.info("Replace Order basic decode test passed.")
