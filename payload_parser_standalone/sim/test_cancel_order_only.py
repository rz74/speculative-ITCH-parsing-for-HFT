import cocotb
from helpers.reset_utils import start_clock, reset_dut

from test_cancel_order import (
    run_cancel_order_basic_test,
    run_garbage_payload_test as run_cancel_garbage_payload_test,
    run_incomplete_payload_test as run_cancel_incomplete_payload_test,
    run_wrong_msg_type_test as run_cancel_wrong_msg_type_test,
    run_multiple_back_to_back_test as run_cancel_multiple_back_to_back_test,
    run_reset_during_decode_test as run_cancel_reset_during_decode_test,
)

@cocotb.test()
async def test_cancel_order_only(dut):
    """Testbench: Only run Cancel Order related tests."""
    await start_clock(dut)
    await reset_dut(dut)

    await run_cancel_order_basic_test(dut)
    await run_cancel_garbage_payload_test(dut)
    await run_cancel_incomplete_payload_test(dut)
    await run_cancel_wrong_msg_type_test(dut)
    await run_cancel_multiple_back_to_back_test(dut)
    await run_cancel_reset_during_decode_test(dut)

    cocotb.log.info("All Cancel Order tests completed successfully.")
