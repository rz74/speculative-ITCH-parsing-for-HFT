# =============================================
# injection_helper.py
# =============================================

# Description: Reusable payload injection patterns for cocotb-based testing.
# Author: RZ
# Start Date: 04172025
# Version: 0.6

# Changelog
# =============================================
# [20250427-1] RZ: Initial helper (random, incomplete, wrong msg types).
# [20250428-1] RZ: Added mid-payload reset injection.
# [20250429-1] RZ: Adopted into injection_helper.py from payload_injection.py.
# [20250429-2] RZ: Added inject_bytes_serially and inject_and_expect_valid_flag.
# [20250429-3] RZ: Updated inject_and_expect_decode.
# [20250502-1] RZ: Added inject_and_expect_parser_output and inject_and_expect_parsed_result.
# [20250502-2] RZ: Added expect_parsed_result_at_cycle for single-cycle flags with absolute tracking.
# =============================================

from cocotb.triggers import RisingEdge, ReadOnly

async def inject_bytes_serially(dut, payload: bytes):
    """Injects bytes into the parser, 1 per cycle, then deasserts valid_in."""
    for b in payload:
        dut.byte_in.value = b
        dut.valid_in.value = 1
        await RisingEdge(dut.clk)
    dut.valid_in.value = 0
    await RisingEdge(dut.clk)  # parsed_valid expected here


async def inject_and_expect_valid_flag(dut, payload: bytes, expected_valid=True):
    await inject_bytes_serially(dut, payload)
    await RisingEdge(dut.clk)
    assert dut.valid_flag.value == int(expected_valid), f"Expected valid_flag={expected_valid}, got {int(dut.valid_flag.value)}"


async def inject_and_expect_decode(dut, payload_generator, decoded_signal):
    payload = payload_generator(0)
    for b in payload:
        dut.byte_in.value = b
        dut.valid_in.value = 1
        await RisingEdge(dut.clk)

    dut.valid_in.value = 0

    for _ in range(5):
        await RisingEdge(dut.clk)
        if decoded_signal.value == 1:
            break

    assert decoded_signal.value == 1, f"Decode signal {decoded_signal._name} was not asserted."


async def inject_reset_midstream(dut, payload, trigger_cycle=2):
    for i, byte in enumerate(payload):
        if i == trigger_cycle:
            dut.rst_n.value = 0
        dut.tcp_payload_in.value = byte
        dut.tcp_byte_valid_in.value = 1
        await RisingEdge(dut.clk)
        if i == trigger_cycle:
            dut.rst_n.value = 1
        await RisingEdge(dut.clk)
    dut.tcp_byte_valid_in.value = 0


async def inject_payload_and_wait(dut, payload: bytes, idle_cycles_after=3):
    """Injects a payload and waits for N idle cycles after transmission."""
    for b in payload:
        dut.byte_in.value = b
        dut.valid_in.value = 1
        await RisingEdge(dut.clk)

    dut.valid_in.value = 0
    for _ in range(idle_cycles_after):
        await RisingEdge(dut.clk)


async def inject_and_expect_parser_output(dut, payload: bytes, max_wait_cycles: int):
    """
    Injects a payload and waits for `parsed_valid` to be asserted.
    - max_wait_cycles: how long to wait after injection before failing
    """
    for byte in payload:
        dut.byte_in.value = byte
        dut.valid_in.value = 1
        await RisingEdge(dut.clk)
    dut.valid_in.value = 0
    await RisingEdge(dut.clk)

    for cycle in range(max_wait_cycles):
        await RisingEdge(dut.clk)
        await ReadOnly()
        if dut.parsed_valid.value == 1:
            dut._log.info(f"parsed_valid detected at cycle offset {cycle}")
            return
    raise AssertionError(f"parsed_valid was never asserted within {max_wait_cycles} cycles after injection.")


async def inject_and_expect_parsed_result(dut, payload: bytes, expected_cycles: int, expected_type: int, expected_order_ref: int):
    """Injects a payload and checks parsed_valid, parsed_type, and order_ref at exact expected cycle."""
    await inject_and_expect_parser_output(dut, payload, expected_cycles)
    assert dut.parsed_type.value == expected_type, f"Expected parsed_type={expected_type}, got {int(dut.parsed_type.value)}"
    assert dut.order_ref.value == expected_order_ref, f"Expected order_ref={hex(expected_order_ref)}, got {hex(int(dut.order_ref.value))}"


async def expect_parsed_result_at_cycle(dut, start_cycle, expected_type, expected_order_ref, timeout=10):
    """
    Waits for parsed_valid to go high within `timeout` cycles after `start_cycle`.
    Returns the absolute cycle number when parsed_valid was asserted.
    """
    for offset in range(timeout):
        await RisingEdge(dut.clk)
        await ReadOnly()
        if dut.parsed_valid.value == 1:
            assert dut.parsed_type.value == expected_type, \
                f"Expected parsed_type={expected_type}, got {int(dut.parsed_type.value)}"
            assert dut.order_ref.value == expected_order_ref, \
                f"Expected order_ref={hex(expected_order_ref)}, got {hex(int(dut.order_ref.value))}"
            return start_cycle + offset

    raise AssertionError(f"parsed_valid not seen within {timeout} cycles after expected cycle {start_cycle}")

async def log_parsed_valid_cycle(dut, start_cycle, label="", timeout=20):
    """
    Waits for parsed_valid to go high within `timeout` cycles after `start_cycle`.
    Logs the cycle and outputs but does not assert.
    """
    for offset in range(timeout):
        await RisingEdge(dut.clk)
        await ReadOnly()
        if dut.parsed_valid.value == 1:
            dut._log.info(
                f"[{label}] parsed_valid seen at cycle {start_cycle + offset} | "
                f"type={int(dut.parsed_type.value)}, "
                f"order_ref=0x{int(dut.order_ref.value):016X}"
            )
            return
    dut._log.warning(f"[{label}] parsed_valid not seen within {timeout} cycles after cycle {start_cycle}")

from cocotb.triggers import RisingEdge, ReadOnly

async def inject_payload_now(dut, payload: bytes):
    """
    Inject payload immediately, 1 byte per cycle with no idle cycles.
    Returns the absolute cycle when injection ends (first idle cycle).
    """
    for b in payload:
        dut.byte_in.value = b
        dut.valid_in.value = 1
        await RisingEdge(dut.clk)
    dut.valid_in.value = 0
    await RisingEdge(dut.clk)  # Injection ends here


async def inject_and_expect_parsed_cycle(
    dut, payload: bytes, start_cycle: int,
    expected_type: int, expected_order_ref: int
):
    """
    Injects payload starting at cycle start_cycle + 1, and watches for parsed_valid
    during and one cycle after injection.
    """
    observed_cycle = start_cycle
    found = False

    # Inject payload while watching for parsed_valid
    for b in payload:
        dut.byte_in.value = b
        dut.valid_in.value = 1
        await RisingEdge(dut.clk)
        observed_cycle += 1
        await ReadOnly()
        if dut.parsed_valid.value == 1:
            found = True
            dut._log.info(f"[parsed_valid] Seen at cycle {observed_cycle}")
            assert dut.parsed_type.value == expected_type
            assert dut.order_ref.value == expected_order_ref
            return observed_cycle

    # One more cycle after injection
    dut.valid_in.value = 0
    await RisingEdge(dut.clk)
    observed_cycle += 1
    await ReadOnly()
    if dut.parsed_valid.value == 1:
        found = True
        dut._log.info(f"[parsed_valid] Seen at cycle {observed_cycle}")
        assert dut.parsed_type.value == expected_type
        assert dut.order_ref.value == expected_order_ref
        return observed_cycle

    raise AssertionError("parsed_valid not seen during or immediately after injection")
