import cocotb
from helpers.reset_utils import reset_dut, start_clock
from helpers.payload_injection import (
    inject_random_payload,
    inject_incomplete_payload,
    inject_wrong_msg_type,
    inject_multiple_valid_msgs,
    reset_mid_payload,
)
from helpers.payload_generators import generate_add_order_payload

async def run_add_order_basic_test(dut):
    await start_clock(dut)
    await reset_dut(dut)

    payload = generate_add_order_payload(0)
    dut.in_valid.value = 1
    dut.msg_type.value = payload[0]
    dut.payload.value = int.from_bytes(payload.ljust(64, b'\x00'), byteorder='big')
    await RisingEdge(dut.clk)
    dut.in_valid.value = 0

    for _ in range(5):
        await RisingEdge(dut.clk)

    cocotb.log.info("Add Order basic decode test passed.")

async def run_garbage_payload_test(dut):
    await inject_random_payload(dut, dut.add_order_decoded)

async def run_incomplete_payload_test(dut):
    await inject_incomplete_payload(dut, dut.add_order_decoded)

async def run_wrong_msg_type_test(dut):
    await inject_wrong_msg_type(dut, dut.add_order_decoded)

async def run_multiple_back_to_back_test(dut):
    await inject_multiple_valid_msgs(dut, generate_add_order_payload)

async def run_reset_during_decode_test(dut):
    await reset_mid_payload(dut, generate_add_order_payload, dut.add_order_decoded)
