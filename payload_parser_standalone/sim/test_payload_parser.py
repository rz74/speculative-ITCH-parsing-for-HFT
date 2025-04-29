# =============================================
# test_payload_parser.py
# =============================================

# Description: Master cocotb testbench for full payload parser (Add, Cancel, Delete, Replace)
# Author: RZ
# Start Date: 04172025
# Version: 0.3

# Changelog
# =============================================
# [20250427-1] RZ: Initial master testbench for add/cancel/delete
# [20250428-1] RZ: Integrated Replace Order into master system test
# =============================================

import cocotb
from cocotb.triggers import RisingEdge
from helpers.reset_utils import start_clock, reset_dut, reset_and_test_decoder_behavior
from helpers.payload_generators import (
    generate_add_order_payload,
    generate_cancel_order_payload,
    generate_delete_order_payload,
    generate_replace_order_payload,
    generate_dummy_payload

)
from helpers.payload_injection import (
    inject_random_payload,
    inject_incomplete_payload,
    inject_wrong_msg_type,
    inject_multiple_valid_msgs,
    reset_mid_payload       

)

@cocotb.test()
async def test_payload_parser(dut):
    """Master top-level test calling add, cancel, delete, and replace order subtests."""
    await start_clock(dut)
    await reset_dut(dut)

    # Add Order
    await run_add_order_basic_test(dut)
    await inject_random_payload(dut, dut.add_order_decoded)
    await inject_incomplete_payload(dut, dut.add_order_decoded)
    await inject_wrong_msg_type(dut, dut.add_order_decoded)
    await inject_multiple_valid_msgs(dut, generate_add_order_payload)
    # await reset_mid_payload(dut, generate_add_order_payload, dut.add_order_decoded)
    await reset_and_test_decoder_behavior(dut, generate_add_order_payload, dut.add_order_decoded, expect_decode_after_reset=True)
    await reset_and_test_decoder_behavior(dut, generate_dummy_payload, dut.add_order_decoded, expect_decode_after_reset=False)

    # Cancel Order
    await run_cancel_order_basic_test(dut)
    await inject_random_payload(dut, dut.cancel_order_decoded)
    await inject_incomplete_payload(dut, dut.cancel_order_decoded)
    await inject_wrong_msg_type(dut, dut.cancel_order_decoded)
    await inject_multiple_valid_msgs(dut, generate_cancel_order_payload)
    # await reset_mid_payload(dut, generate_cancel_order_payload, dut.cancel_order_decoded)
    await reset_and_test_decoder_behavior(dut, generate_cancel_order_payload, dut.cancel_order_decoded, expect_decode_after_reset=True)
    await reset_and_test_decoder_behavior(dut, generate_dummy_payload, dut.cancel_order_decoded, expect_decode_after_reset=False)


    # Delete Order
    await run_delete_order_basic_test(dut)
    await inject_random_payload(dut, dut.delete_order_decoded)
    await inject_incomplete_payload(dut, dut.delete_order_decoded)
    await inject_wrong_msg_type(dut, dut.delete_order_decoded)
    await inject_multiple_valid_msgs(dut, generate_delete_order_payload)
    # await reset_mid_payload(dut, generate_delete_order_payload, dut.delete_order_decoded)
    await reset_and_test_decoder_behavior(dut, generate_delete_order_payload, dut.delete_order_decoded, expect_decode_after_reset=True)
    await reset_and_test_decoder_behavior(dut, generate_dummy_payload, dut.delete_order_decoded, expect_decode_after_reset=False)


    # Replace Order 
    await run_replace_order_basic_test(dut)
    await inject_random_payload(dut, dut.replace_order_decoded)
    await inject_incomplete_payload(dut, dut.replace_order_decoded)
    await inject_wrong_msg_type(dut, dut.replace_order_decoded)
    await inject_multiple_valid_msgs(dut, generate_replace_order_payload)
    # await reset_mid_payload(dut, generate_replace_order_payload, dut.replace_order_decoded)
    await reset_and_test_decoder_behavior(dut, generate_replace_order_payload, dut.replace_order_decoded, expect_decode_after_reset=True)
    await reset_and_test_decoder_behavior(dut, generate_dummy_payload, dut.replace_order_decoded, expect_decode_after_reset=False)


    cocotb.log.info("All full payload parser tests completed successfully.")

async def run_add_order_basic_test(dut):
    payload = generate_add_order_payload(0)
    dut.in_valid.value = 1
    dut.msg_type.value = payload[0]
    dut.payload.value = int.from_bytes(payload.ljust(64, b'\x00'), byteorder='big')
    await RisingEdge(dut.clk)
    dut.in_valid.value = 0
    for _ in range(5):
        await RisingEdge(dut.clk)
    cocotb.log.info("Add Order basic decode test passed.")

async def run_cancel_order_basic_test(dut):
    payload = generate_cancel_order_payload(0)
    dut.in_valid.value = 1
    dut.msg_type.value = payload[0]
    dut.payload.value = int.from_bytes(payload.ljust(64, b'\x00'), byteorder='big')
    await RisingEdge(dut.clk)
    dut.in_valid.value = 0
    for _ in range(5):
        await RisingEdge(dut.clk)
    cocotb.log.info("Cancel Order basic decode test passed.")

async def run_delete_order_basic_test(dut):
    payload = generate_delete_order_payload(0)
    dut.in_valid.value = 1
    dut.msg_type.value = payload[0]
    dut.payload.value = int.from_bytes(payload.ljust(64, b'\x00'), byteorder='big')
    await RisingEdge(dut.clk)
    dut.in_valid.value = 0
    for _ in range(5):
        await RisingEdge(dut.clk)
    cocotb.log.info("Delete Order basic decode test passed.")

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
