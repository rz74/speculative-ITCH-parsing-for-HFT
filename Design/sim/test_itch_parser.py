import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from helpers.payload_generator_helper import generate_add_order_payload, generate_cancel_order_payload
from helpers.injection_helper import inject_payload_and_wait
from helpers.assertion_helper import assert_output_fields

@cocotb.test()
async def test_itch_parser_add_then_cancel(dut):
    """Send one Add and one Cancel message through full ITCH parser"""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut._log.info("Starting ITCH parser integration test")

    # Reset
    dut.rst.value = 1
    dut.valid_in.value = 0
    dut.byte_in.value = 0
    for _ in range(3):
        await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Inject a valid Add Order packet
    add_payload = generate_add_order_payload(index=1)
    await inject_payload_and_wait(dut, add_payload)

    # Wait for parsed_valid pulse
    for _ in range(10):
        await RisingEdge(dut.clk)
        if dut.parsed_valid.value == 1:
            break
    assert dut.parsed_valid.value == 1, "parsed_valid not asserted after Add Order"

    expected_add = {
        "parsed_type": 1,
        "order_ref": int.from_bytes(add_payload[1:9], 'big'),
        "side": add_payload[9] & 0x1,
        "shares": int.from_bytes(add_payload[10:14], 'big'),
        "price": int.from_bytes(add_payload[14:22], 'big'),
        "stock_symbol": int.from_bytes(add_payload[14:22], 'big')  # reusing price field as symbol for now
    }
    await assert_output_fields(dut, expected_add)

    # Inject a valid Cancel Order packet
    cancel_payload = generate_cancel_order_payload(index=1)
    await inject_payload_and_wait(dut, cancel_payload)

    # Wait for parsed_valid pulse again
    for _ in range(10):
        await RisingEdge(dut.clk)
        if dut.parsed_valid.value == 1:
            break
    assert dut.parsed_valid.value == 1, "parsed_valid not asserted after Cancel Order"

    expected_cancel = {
        "parsed_type": 2,
        "order_ref": int.from_bytes(cancel_payload[1:9], 'big'),
        "shares": int.from_bytes(cancel_payload[9:13], 'big')
    }
    await assert_output_fields(dut, expected_cancel)

    dut._log.info("ITCH parser integration test passed")
