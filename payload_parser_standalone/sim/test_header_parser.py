# =============================================
# test_header_parser.py
# =============================================

# Description: Cocotb testbench for validating the Header Parser module (speculative mode).
# Author: RZ
# Start Date: 04292025
# Version: 0.4

# Changelog
# =============================================
# [20250429-1] RZ: Initial version created for header_parser standalone validation.
# [20250429-2] RZ: Patched deprecated assignment syntax and added clock driver.
# [20250429-3] RZ: Integrated reset_utils.py helpers (start_clock and reset_dut).
# [20250429-4] RZ: Updated for full speculative decode behavior (one cycle delay allowed).
# =============================================

import cocotb
from cocotb.triggers import RisingEdge
from helpers.reset_utils import start_clock, reset_dut

@cocotb.test()
async def header_parser_basic_test(dut):
    """Basic functionality test for header_parser"""

    # Start clock using helper
    await start_clock(dut)

    # Apply reset using helper
    await reset_dut(dut)

    # Define a fake TCP payload stream
    payload_stream = [0x2A, 0x3B, 0x4C]

    # Inject the payload into the DUT
    for idx, byte in enumerate(payload_stream):
        dut.tcp_payload_in.value = byte
        dut.tcp_byte_valid_in.value = 1
        await RisingEdge(dut.clk)

        # Wait one additional clock cycle to allow data to latch (speculative mode)
        await RisingEdge(dut.clk)

        # Check payload output and valid signal
        assert dut.payload_out.value.integer == byte, \
            f"Payload mismatch at byte {idx}: expected {hex(byte)}, got {hex(dut.payload_out.value.integer)}"

        assert dut.payload_valid_out.value == 1, \
            f"Payload valid not asserted at byte {idx}"

        # Check start_flag only on the first byte
        if idx == 0:
            assert dut.start_flag.value == 1, "Start flag not asserted on first byte"
        else:
            assert dut.start_flag.value == 0, "Start flag wrongly asserted after first byte"

    # After sending all bytes, drop valid
    dut.tcp_byte_valid_in.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    # Confirm outputs idle
    assert dut.payload_valid_out.value == 0, "Payload valid should be deasserted after end of stream"

    cocotb.log.info("Header parser basic test PASSED")
