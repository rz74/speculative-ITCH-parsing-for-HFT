# =============================================
# injection_helper.py
# =============================================

# Description: Reusable payload injection patterns for cocotb-based testing.
# Author: RZ
# Start Date: 04172025
# Version: 0.5

# Changelog
# =============================================
# [20250427-1] RZ: Initial helper (random, incomplete, wrong msg types).
# [20250428-1] RZ: Added mid-payload reset injection.
# [20250429-1] RZ: Adopted into injection_helper.py from payload_injection.py.
# [20250429-2] RZ: Added inject_bytes_serially and inject_and_expect_valid_flag.
# [20250429-3] RZ: Updated inject_and_expect_decode.
# =============================================

from cocotb.triggers import RisingEdge

async def inject_bytes_serially(dut, payload: bytes):
    for b in payload:
        dut.tcp_payload_in.value = b
        dut.tcp_byte_valid_in.value = 1
        await RisingEdge(dut.clk)
        await RisingEdge(dut.clk)
    dut.tcp_byte_valid_in.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

async def inject_and_expect_valid_flag(dut, payload: bytes, expected_valid=True):
    await inject_bytes_serially(dut, payload)
    await RisingEdge(dut.clk)
    assert dut.valid_flag.value == int(expected_valid), f"Expected valid_flag={expected_valid}, got {int(dut.valid_flag.value)}"
 

async def inject_and_expect_decode(dut, payload_generator, decoded_signal):
    payload = payload_generator(0)

    for i, b in enumerate(payload):
        dut.tcp_payload_in.value = b
        dut.tcp_byte_valid_in.value = 1
        dut.start_flag.value = 1 if i == 0 else 0
        await RisingEdge(dut.clk)

    # Deassert after stream ends
    dut.tcp_byte_valid_in.value = 0
    dut.start_flag.value = 0

    # Wait a few cycles to catch decode pulse
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
