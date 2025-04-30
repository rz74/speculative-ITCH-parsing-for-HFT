# =============================================
# test_header_parser.py
# =============================================

# Description: Cocotb testbench for validating the Header Parser module (speculative mode).
# Author: RZ
# Start Date: 04292025
# Version: 0.8

# Changelog
# =============================================
# [20250429-1] RZ: Initial version created for header_parser standalone validation.
# [20250429-2] RZ: Patched deprecated assignment syntax and added clock driver.
# [20250429-3] RZ: Integrated reset_utils.py helpers (start_clock and reset_dut).
# [20250429-4] RZ: Updated for full speculative decode behavior (one cycle delay allowed).
# [20250429-5] RZ: Refactored to use new helpers from reset_helper, injection_helper, assertion_helper.
# [20250429-6] RZ: Integrated header_generator_helper to generate structured valid headers.
# [20250429-7] RZ: Added tests for invalid and random headers, replaced hardcoded payload with randomized stream.
# [20250429-8] RZ: Added test for speculative decode of random valid headers.

# =============================================

import cocotb
import random
from cocotb.triggers import RisingEdge
from helpers.reset_helper import start_clock, reset_dut
from helpers.assertion_helper import verify_start_flag_high
from helpers.payload_generator_helper import generate_random_valid_payload
from helpers.header_generator_helper import (
    generate_header,
    generate_invalid_header,
    generate_random_header,
    generate_random_valid_header
)

@cocotb.test()
async def header_parser_basic_test(dut):
    '''Basic functionality test for header_parser using structured header + random payload'''

    await start_clock(dut)
    await reset_dut(dut)
    await RisingEdge(dut.clk)

    # header = generate_header('A', 42)
    header = generate_random_valid_header()
    # payload = [random.randint(0, 255) for _ in range(5)]
    payload = list(generate_random_valid_payload(0)[:2])
    payload_stream = list(header) + payload

    dut.tcp_byte_valid_in.value = 1
    for idx, byte in enumerate(payload_stream):
        dut.tcp_payload_in.value = byte
        await RisingEdge(dut.clk)
        await RisingEdge(dut.clk)

        assert dut.payload_out.value == byte, f"Byte {idx} mismatch: expected {hex(byte)}, got {hex(dut.payload_out.value.integer)}"
        assert dut.payload_valid_out.value == 1, f"payload_valid_out not asserted at byte {idx}"

        if idx == 0:
            await verify_start_flag_high(dut)
        else:
            assert dut.start_flag.value == 0, "start_flag should only be high for first byte"

    dut.tcp_byte_valid_in.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    assert dut.payload_valid_out.value == 0, "payload_valid_out should deassert after input ends"

    cocotb.log.info("Header parser basic test PASSED")


@cocotb.test()
async def header_parser_invalid_header_test(dut):
    '''Verify header_parser speculatively raises start_flag even for malformed header'''

    await start_clock(dut)
    await reset_dut(dut)
    await RisingEdge(dut.clk)

    header = generate_invalid_header()
    dut.tcp_byte_valid_in.value = 1

    for idx, byte in enumerate(header):
        dut.tcp_payload_in.value = byte
        await RisingEdge(dut.clk)
        await RisingEdge(dut.clk)

        assert dut.payload_out.value == byte, f"Invalid byte {idx} mismatch"
        assert dut.payload_valid_out.value == 1, f"payload_valid_out not asserted at byte {idx}"

        if idx == 0:
            await verify_start_flag_high(dut)
        else:
            assert dut.start_flag.value == 0, "start_flag should only be high on first byte"

    dut.tcp_byte_valid_in.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    cocotb.log.info("Header parser invalid header test PASSED (start_flag asserted speculatively)")



@cocotb.test()
async def header_parser_random_header_test(dut):
    '''Test parser with randomized valid headers (speculative decode regardless of content)'''

    await start_clock(dut)
    await reset_dut(dut)
    await RisingEdge(dut.clk)

    header = generate_random_header()
    payload = [random.randint(0, 255) for _ in range(4)]
    stream = list(header) + payload

    dut.tcp_byte_valid_in.value = 1
    for idx, byte in enumerate(stream):
        dut.tcp_payload_in.value = byte
        await RisingEdge(dut.clk)
        await RisingEdge(dut.clk)

        assert dut.payload_out.value == byte, f"Mismatch at byte {idx}: {hex(byte)} vs {hex(dut.payload_out.value.integer)}"
        assert dut.payload_valid_out.value == 1, f"payload_valid_out not asserted at byte {idx}"

        if idx == 0:
            await verify_start_flag_high(dut)
        else:
            assert dut.start_flag.value == 0, "start_flag should only be high on first byte"

    dut.tcp_byte_valid_in.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    assert dut.payload_valid_out.value == 0, "payload_valid_out should deassert after stream"

    cocotb.log.info("Header parser random header test PASSED (speculative mode)")

