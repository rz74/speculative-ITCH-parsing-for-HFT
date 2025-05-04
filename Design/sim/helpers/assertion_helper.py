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
from cocotb.triggers import Timer, RisingEdge
from cocotb.utils import get_sim_time
from sim_config import SIM_CLK_PERIOD_NS
from helpers.recorder import EXPECTED_VALID_SIGNALS


def compare_recorded_vs_expected(signal_log, injection_schedule):
    errors = 0
    for entry in injection_schedule:
        expected_cycle = entry["expected_valid_cycle"]
        signal_name = EXPECTED_VALID_SIGNALS[entry["type"]]
        value_at_expected = signal_log.get(expected_cycle, {}).get(signal_name, 0)

        if value_at_expected != 1:
            print(f"[FAIL] {signal_name} was NOT high at cycle {expected_cycle}")
            errors += 1
        else:
            print(f"[PASS] {signal_name} correctly high at cycle {expected_cycle}")

    assert errors == 0, f"{errors} signal(s) failed to assert at expected cycles"

# async def assert_add_valid_at_cycle(dut, start_cycle):
#     injection_time_ns = start_cycle * SIM_CLK_PERIOD_NS
#     target_cycle = start_cycle + 36
#     target_time_ns = target_cycle * SIM_CLK_PERIOD_NS

#     check_start_time = target_time_ns - 2 * SIM_CLK_PERIOD_NS  # 360ns
#     check_end_time   = target_time_ns + 2 * SIM_CLK_PERIOD_NS  # 400ns
#     found = False

#     dut._log.info(f"=== DEBUG: Checking add_internal_valid around {target_time_ns}ns (target cycle {target_cycle}) ===")
#     dut._log.info(f"       Scanning from {check_start_time}ns to {check_end_time}ns")

#     cycles_to_check = int((check_end_time - check_start_time) // SIM_CLK_PERIOD_NS)

#     for _ in range(cycles_to_check):
#         await RisingEdge(dut.clk)
#         sim_time = get_sim_time('ns')
#         abs_cycle = sim_time // SIM_CLK_PERIOD_NS
#         val = dut.add_internal_valid.value

#         dut._log.info(f"[Cycle {abs_cycle} | {sim_time}ns] add_internal_valid = {int(val)}")

#         if target_time_ns <= sim_time < target_time_ns + SIM_CLK_PERIOD_NS:
#             if val.is_resolvable and val:
#                 found = True

#     # assert found, (
#     #     f"add_internal_valid not high at exact expected time {target_time_ns}ns (cycle {target_cycle})"
#     # )




# async def assert_cancel_valid_at_cycle(dut, start_cycle):
#     target_cycle = start_cycle + 23
#     start_time_ns = target_cycle * SIM_CLK_PERIOD_NS
#     end_time_ns = start_time_ns + SIM_CLK_PERIOD_NS
#     found = False

#     dut._log.info(f"=== DEBUG: Checking cancel_internal_valid in window [{start_time_ns}ns, {end_time_ns}ns) ===")

#     while True:
#         await RisingEdge(dut.clk)
#         sim_time = get_sim_time('ns')
#         if sim_time >= end_time_ns:
#             break
#         if start_time_ns <= sim_time < end_time_ns:
#             val = dut.cancel_internal_valid.value
#             if val.is_resolvable and val:
#                 dut._log.info(f"[{sim_time}ns] cancel_internal_valid = 1 (within expected window)")
#                 found = True
#             else:
#                 dut._log.info(f"[{sim_time}ns] cancel_internal_valid = 0 (within expected window)")

#     # assert found, f"cancel_internal_valid not high between {start_time_ns}ns and {end_time_ns}ns"

# def assert_valid_wrapper(dut, msg_type, start_cycle):
#     if msg_type == "add":
#         return assert_add_valid_at_cycle(dut, start_cycle)
#     elif msg_type == "cancel":
#         return assert_cancel_valid_at_cycle(dut, start_cycle)
#     else:
#         raise ValueError(f"Unsupported message type: {msg_type}")

# async def debug_internal_valid_signals(dut, label, duration_cycles=100):
    dut._log.info(f"[{label}] === DEBUG: Sampling internal_valid signals from current cycle ===")
    for _ in range(duration_cycles):
        await RisingEdge(dut.clk)
        sim_time = get_sim_time('ns')
        abs_cycle = sim_time // SIM_CLK_PERIOD_NS

        add_val = dut.add_internal_valid.value
        cancel_val = dut.cancel_internal_valid.value

        dut._log.info(
            f"[{label}] Cycle={abs_cycle} | {sim_time}ns | add_internal_valid={int(add_val)} | cancel_internal_valid={int(cancel_val)}"
        )


# ================================================================

# async def assert_decode_pulse(dut, signal, window=5):
#     for _ in range(window):
#         await RisingEdge(dut.clk)
#         if signal.value == 1:
#             return
#     raise AssertionError(f"{signal._name} never pulsed within {window} cycles.")

# async def assert_output_fields(dut, expected_fields: dict):
#     for name, expected in expected_fields.items():
#         actual = getattr(dut, name).value.integer
#         assert actual == expected, f"{name} mismatch: expected {hex(expected)}, got {hex(actual)}"

# async def wait_for_signal(signal, expected_value, timeout=5):
#     for _ in range(timeout):
#         if signal.value == expected_value:
#             return
#         await RisingEdge(signal._path_toplevel.clk)
#     raise AssertionError(f"{signal._name} did not reach value {expected_value} in {timeout} cycles.")

# async def verify_start_flag_high(dut):
#     assert dut.start_flag.value == 1, "start_flag should be high on first valid byte"


