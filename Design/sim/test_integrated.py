
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.binary import BinaryValue

@cocotb.test()
async def test_add_then_cancel_no_pause(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Reset
    dut.rst.value = 1
    dut.valid_in.value = 0
    dut.byte_in.value = 0
    for _ in range(3):
        await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Helper to drive a byte stream into the DUT
    async def send_bytes(byte_list):
        for b in byte_list:
            dut.byte_in.value = b
            dut.valid_in.value = 1
            await RisingEdge(dut.clk)
        dut.valid_in.value = 0

# Construct an Add Order ('A') message - 36 bytes
    add_payload = [
        ord('A'),                              # [0] Type
        *b'\x01\x23\x45\x67\x89\xAB\xCD\xEF',  # [1:8] Order Ref
        ord('B'),                              # [9] Side
        *b'\x00\x00\x00\x64',                  # [10:13] Shares = 100
        *b'ABCD1234',                          # [14:21] Symbol
        *b'\x00\x00\x0F\xA0'                   # [22:25] Price = 4000
    ] + list(range(1, 11))                     # [26:35] Padding: 1~10

    # Construct a Cancel Order ('X') message - 23 bytes
    cancel_payload = [
        ord('X'),                              # [0] Type
        *b'\xFE\xDC\xBA\x98\x76\x54\x32\x10',  # [1:8] Order Ref
        *b'\x00\x00\x00\x32'                   # [9:12] Canceled Shares = 50
    ] + list(range(11, 21))                    # [13:22] Padding: 11~20


    # Inject Add + Cancel without pause
    await send_bytes(add_payload + add_payload + cancel_payload + cancel_payload + add_payload + add_payload + cancel_payload + cancel_payload)

    # Wait for both decoders to complete
    found_add = False
    found_cancel = False
    for _ in range(100):
        await RisingEdge(dut.clk)
        if dut.add_internal_valid.value:
            found_add = True
            dut._log.info("Add Order detected.")
        if dut.cancel_internal_valid.value:
            found_cancel = True
            dut._log.info("Cancel Order detected.")
        if found_add and found_cancel:
            break

    assert found_add, "Add decoder did not fire"
    assert found_cancel, "Cancel decoder did not fire"
