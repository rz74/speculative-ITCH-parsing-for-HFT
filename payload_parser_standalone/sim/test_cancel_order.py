import cocotb
from cocotb.triggers import RisingEdge
from helpers.reset_utils import reset_dut, start_clock
from helpers.payload_injection import (
    inject_random_payload,
    inject_incomplete_payload,
    inject_wrong_msg_type,
    inject_multiple_valid_msgs,
    reset_mid_payload,
)
from helpers.payload_generators import generate_cancel_order_payload

async def run_cancel_order_basic_test(dut):
    """Test for basic Cancel Order decoding."""
    payload = generate_cancel_order_payload(0)

    dut.in_valid.value = 1
    dut.msg_type.value = payload[0]  # Should be ASCII for 'X'
    dut.payload.value = int.from_bytes(payload.ljust(64, b'\x00'), byteorder='big')

    await RisingEdge(dut.clk)
    dut.in_valid.value = 0

    for _ in range(5):
        await RisingEdge(dut.clk)

    cocotb.log.info("Cancel Order basic decode test passed.")

async def run_garbage_payload_test(dut):
    await inject_random_payload(dut, dut.cancel_order_decoded)

async def run_incomplete_payload_test(dut):
    await inject_incomplete_payload(dut, dut.cancel_order_decoded)

async def run_wrong_msg_type_test(dut):
    await inject_wrong_msg_type(dut, dut.cancel_order_decoded)

async def run_multiple_back_to_back_test(dut):
    await inject_multiple_valid_msgs(dut, generate_cancel_order_payload)

async def run_reset_during_decode_test(dut):
    await reset_mid_payload(dut, generate_cancel_order_payload, dut.cancel_order_decoded)
