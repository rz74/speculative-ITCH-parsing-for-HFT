# =============================================
# assertion_helper.py
# =============================================

# Description: Common signal verification and decoder field assertions.
# Author: RZ
# Start Date: 20250429
# Version: 0.1

# Changelog
# =============================================
# [20250429-1] RZ: Initial version. Abstracted field value assertions and decode pulse checks from individual testbenches.
# =============================================

from cocotb.triggers import RisingEdge

async def assert_decode_pulse(dut, signal, window=5):
    for _ in range(window):
        await RisingEdge(dut.clk)
        if signal.value == 1:
            return
    raise AssertionError(f"{signal._name} never pulsed within {window} cycles.")

async def assert_output_fields(dut, expected_fields: dict):
    for name, expected in expected_fields.items():
        actual = getattr(dut, name).value.integer
        assert actual == expected, f"{name} mismatch: expected {hex(expected)}, got {hex(actual)}"

async def wait_for_signal(signal, expected_value, timeout=5):
    for _ in range(timeout):
        if signal.value == expected_value:
            return
        await RisingEdge(signal._path_toplevel.clk)
    raise AssertionError(f"{signal._name} did not reach value {expected_value} in {timeout} cycles.")

async def verify_start_flag_high(dut):
    assert dut.start_flag.value == 1, "start_flag should be high on first valid byte"


