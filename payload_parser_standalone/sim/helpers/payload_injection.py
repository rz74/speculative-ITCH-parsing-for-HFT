# =============================================
# payload_injection_helpers.py
# =============================================

# Description: Helper utilities for injecting random, incomplete, wrong, and multiple payloads for cocotb testing.
# Author: RZ
# Start Date: 04172025
# Version: 0.1

# Changelog
# =============================================
# [20250427-1] RZ: Initial version for payload injection helpers (random, incomplete, wrong type, multiple).
# [20250428-1] RZ: Added mid-payload reset test for robustness.
# =============================================

import cocotb
from cocotb.triggers import RisingEdge
import random

async def inject_random_payload(dut, decoded_signal):
    garbage = random.getrandbits(512).to_bytes(64, 'big')
    dut.in_valid.value = 1
    dut.msg_type.value = random.randint(0x20, 0x7E)
    dut.payload.value = int.from_bytes(garbage, byteorder='big')
    await RisingEdge(dut.clk)
    dut.in_valid.value = 0
    await RisingEdge(dut.clk)
    assert decoded_signal.value == 0, "Unexpected decoding of random garbage!"
    cocotb.log.info("Garbage payload injected without triggering decode.")

async def inject_incomplete_payload(dut, decoded_signal):
    incomplete = bytearray(32)
    incomplete[0] = ord('A')
    dut.in_valid.value = 1
    dut.msg_type.value = ord('A')
    dut.payload.value = int.from_bytes(incomplete.ljust(64, b'\x00'), byteorder='big')
    await RisingEdge(dut.clk)
    dut.in_valid.value = 0
    await RisingEdge(dut.clk)
    assert decoded_signal.value == 0, "Unexpected decoding of incomplete payload!"
    cocotb.log.info("Incomplete payload injected without triggering decode.")

async def inject_wrong_msg_type(dut, decoded_signal):
    dummy = bytearray(64)
    dummy[0] = ord('Z')
    dut.in_valid.value = 1
    dut.msg_type.value = ord('Z')
    dut.payload.value = int.from_bytes(dummy, byteorder='big')
    await RisingEdge(dut.clk)
    dut.in_valid.value = 0
    await RisingEdge(dut.clk)
    assert decoded_signal.value == 0, "Unexpected decoding on wrong msg type!"
    cocotb.log.info("Wrong msg type injected and correctly ignored.")

async def inject_multiple_valid_msgs(dut, payload_generator):
    for i in range(3):
        payload = payload_generator(i)
        dut.in_valid.value = 1
        dut.msg_type.value = payload[0]
        dut.payload.value = int.from_bytes(payload.ljust(64, b'\x00'), byteorder='big')
        await RisingEdge(dut.clk)
        dut.in_valid.value = 0
        for _ in range(2):
            await RisingEdge(dut.clk)
    cocotb.log.info("Multiple valid payloads injected back-to-back.")

async def reset_mid_payload(dut, payload_generator, decoded_signal):
    payload = payload_generator(0)
    dut.in_valid.value = 1
    dut.msg_type.value = payload[0]
    dut.payload.value = int.from_bytes(payload.ljust(64, b'\x00'), byteorder='big')
    await RisingEdge(dut.clk)

    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    dut.in_valid.value = 0 # Clear in_valid to avoid triggering decode. mimic system behavior.
    await RisingEdge(dut.clk)

    dut.in_valid.value = 0
    await RisingEdge(dut.clk)
    assert decoded_signal.value == 0, "Decode should have been cleared after reset!"
    cocotb.log.info("Reset during decode handled cleanly.")