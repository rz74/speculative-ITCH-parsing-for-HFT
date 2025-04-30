# =============================================
# test_add_order_only.py
# =============================================

# Description: Cocotb testbench for validating Add Order ('A') decoder in speculative pipeline.
# Author: RZ
# Start Date: 04172025
# Version: 0.4

# Changelog
# =============================================
# [20250427-1] RZ: Initial version created for Add Order only testing.
# [20250428-1] RZ: Modularized with project structure.
# [20250429-1] RZ: Refactored to use top_test.v and unified helper structure.
# [20250429-2] RZ: Updated to use inject_and_expect_decode from injection_helper.
# =============================================

import cocotb
from cocotb.triggers import RisingEdge
from helpers.reset_helper import start_clock, reset_dut
from helpers.payload_generator_helper import generate_add_order_payload
from helpers.injection_helper import (
    inject_and_expect_decode,
    inject_bytes_serially,
    inject_reset_midstream
)
from helpers.assertion_helper import assert_decode_pulse

@cocotb.test()
async def add_order_basic_decode_test(dut):
    """Verify Add Order decoder parses correctly with speculative length validation."""

    await start_clock(dut)
    await reset_dut(dut)

    payload = generate_add_order_payload(0)

    # Start with length_valid deasserted
    dut.length_valid.value = 0
    dut.expected_length.value = 0

    # Schedule delayed length_valid (simulate header parser behavior)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.expected_length.value = len(payload)-1  # -1 for start byte
    dut.length_valid.value = 1

    # Inject payload as stream
    for i, b in enumerate(payload):
        dut.tcp_payload_in.value = b
        dut.tcp_byte_valid_in.value = 1
        dut.start_flag.value = 1 if i == 0 else 0
        await RisingEdge(dut.clk)

    # Cleanup
    dut.tcp_byte_valid_in.value = 0
    dut.start_flag.value = 0
    dut.length_valid.value = 0

    # Wait a few cycles for commit
    for _ in range(5):
        await RisingEdge(dut.clk)

    assert dut.add_order_decoded.value == 1, "add_order_decoded was not asserted at expected point"
    cocotb.log.info("Add Order basic decode test PASSED with speculative length validation.")



@cocotb.test()
async def add_order_reset_midstream_test(dut):
    """Check Add Order decoder handles mid-payload reset"""

    await start_clock(dut)
    await reset_dut(dut)

    payload = list(generate_add_order_payload(0))
    await inject_reset_midstream(dut, payload, trigger_cycle=3)

    cocotb.log.info("Add Order reset-resilience test PASSED.")
