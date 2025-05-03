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


from cocotb.triggers import RisingEdge

async def inject_payload(dut, payload: list[int]):
    """
    Inject a single payload with valid_in held HIGH during each byte.
    No idle cycles before or after.
    """
    for byte in payload:
        dut.byte_in.value = byte
        dut.valid_in.value = 1
        await RisingEdge(dut.clk)
    # dut.valid_in.value = 0  # Deassert after last byte


async def inject_sequence(dut, payloads: list[list[int]]):
    """
    Inject multiple payloads back-to-back with no gaps between them.
    Each payload is a list of bytes.
    """
    for payload in payloads:
        await inject_payload(dut, payload)

async def inject_payload_by_type(dut, msg_type: str):
    from .payload_generator_helper import generate_payload_by_type
    payload = generate_payload_by_type(msg_type)
    await inject_payload(dut, payload)







# =========================================================================

# async def inject_bytes_serially(dut, payload: bytes):
#     for b in payload:
#         dut.byte_in.value = b
#         dut.valid_in.value = 1
#         await RisingEdge(dut.clk)
#     dut.valid_in.value = 0
#     await RisingEdge(dut.clk)


# async def inject_and_expect_valid_flag(dut, payload: bytes, expected_valid=True):
#     await inject_bytes_serially(dut, payload)
#     await RisingEdge(dut.clk)
#     assert dut.valid_flag.value == int(expected_valid), f"Expected valid_flag={expected_valid}, got {int(dut.valid_flag.value)}"
 

# async def inject_and_expect_decode(dut, payload_generator, decoded_signal):
#     payload = payload_generator(0)

#     for b in payload:
#         dut.byte_in.value = b
#         dut.valid_in.value = 1
#         await RisingEdge(dut.clk)

#     dut.valid_in.value = 0

#     for _ in range(5):
#         await RisingEdge(dut.clk)
#         if decoded_signal.value == 1:
#             break

#     assert decoded_signal.value == 1, f"Decode signal {decoded_signal._name} was not asserted."


# async def inject_reset_midstream(dut, payload, trigger_cycle=2):
#     for i, byte in enumerate(payload):
#         if i == trigger_cycle:
#             dut.rst_n.value = 0
#         dut.tcp_payload_in.value = byte
#         dut.tcp_byte_valid_in.value = 1
#         await RisingEdge(dut.clk)
#         if i == trigger_cycle:
#             dut.rst_n.value = 1
#         await RisingEdge(dut.clk)
#     dut.tcp_byte_valid_in.value = 0


# async def inject_payload_and_wait(dut, payload: bytes, idle_cycles_after=3):
#     """Injects a payload and waits for N idle cycles after transmission."""
#     for b in payload:
#         dut.byte_in.value = b
#         dut.valid_in.value = 1
#         await RisingEdge(dut.clk)

#     dut.valid_in.value = 0
#     for _ in range(idle_cycles_after):
#         await RisingEdge(dut.clk)

