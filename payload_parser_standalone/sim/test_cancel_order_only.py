# =============================================
# test_cancel_order_only.py
# =============================================

# Description: Cocotb testbench for validating Cancel Order ('X') decoding only.
# Author: RZ
# Start Date: 04172025
# Version: 0.1

# Changelog
# =============================================
# [20250427-1] RZ: Initial version created for Cancel Order only testing.
# [20250428-1] RZ: Integrated with modular payload_parser project structure.
# [20250428-2] RZ: Removed incomplete payload testing from module-level testbench for clean modularity.
# [20250428-3] RZ: Added valid flag log
# =============================================

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
    cocotb.log.info(f"[LOG] Cancel Order valid_flag: {dut.cancel_order_valid_flag.value}")


    await run_cancel_garbage_payload_test(dut)
    await run_cancel_incomplete_payload_test(dut)
    await run_cancel_wrong_msg_type_test(dut)
    await run_cancel_multiple_back_to_back_test(dut)
    await run_cancel_reset_during_decode_test(dut)

    cocotb.log.info("All Cancel Order tests completed successfully.")
