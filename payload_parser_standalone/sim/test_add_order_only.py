import cocotb
from helpers.reset_utils import start_clock, reset_dut

from test_add_order import (
    run_add_order_basic_test,
    run_garbage_payload_test as run_add_garbage_payload_test,
    run_incomplete_payload_test as run_add_incomplete_payload_test,
    run_wrong_msg_type_test as run_add_wrong_msg_type_test,
    run_multiple_back_to_back_test as run_add_multiple_back_to_back_test,
    run_reset_during_decode_test as run_add_reset_during_decode_test,
)

@cocotb.test()
async def test_add_order_only(dut):
    """Testbench: Only run Add Order related tests."""
    await start_clock(dut)
    await reset_dut(dut)

    await run_add_order_basic_test(dut)
    await run_add_garbage_payload_test(dut)
    await run_add_incomplete_payload_test(dut)
    await run_add_wrong_msg_type_test(dut)
    await run_add_multiple_back_to_back_test(dut)
    await run_add_reset_during_decode_test(dut)

    cocotb.log.info("All Add Order tests completed successfully.")
