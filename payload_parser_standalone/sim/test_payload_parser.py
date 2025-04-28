import cocotb
from helpers.reset_utils import reset_dut, start_clock

from test_add_order import (
    run_add_order_basic_test,
    run_garbage_payload_test as run_add_garbage_payload_test,
    run_incomplete_payload_test as run_add_incomplete_payload_test,
    run_wrong_msg_type_test as run_add_wrong_msg_type_test,
    run_multiple_back_to_back_test as run_add_multiple_back_to_back_test,
    run_reset_during_decode_test as run_add_reset_during_decode_test,
)

from test_cancel_order import (
    run_cancel_order_basic_test,
    run_garbage_payload_test as run_cancel_garbage_payload_test,
    run_incomplete_payload_test as run_cancel_incomplete_payload_test,
    run_wrong_msg_type_test as run_cancel_wrong_msg_type_test,
    run_multiple_back_to_back_test as run_cancel_multiple_back_to_back_test,
    run_reset_during_decode_test as run_cancel_reset_during_decode_test,
)

@cocotb.test()
async def test_payload_parser(dut):
    """Master top-level test calling add and cancel order subtests."""
    await start_clock(dut)
    await reset_dut(dut)

    # Add Order Tests
    await run_add_order_basic_test(dut)
    await run_add_garbage_payload_test(dut)
    await run_add_incomplete_payload_test(dut)
    await run_add_wrong_msg_type_test(dut)
    await run_add_multiple_back_to_back_test(dut)
    await run_add_reset_during_decode_test(dut)

    # Cancel Order Tests
    await run_cancel_order_basic_test(dut)
    await run_cancel_garbage_payload_test(dut)
    await run_cancel_incomplete_payload_test(dut)
    await run_cancel_wrong_msg_type_test(dut)
    await run_cancel_multiple_back_to_back_test(dut)
    await run_cancel_reset_during_decode_test(dut)

    cocotb.log.info("All payload parser tests completed successfully.")
