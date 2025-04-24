# placeholderimport cocotb
from cocotb.triggers import RisingEdge
from cocotb.result import TestFailure
from cocotb.clock import Clock
from cocotb.triggers import Timer

@cocotb.test()
async def test_itch_header_parser(dut):
    # Setup: start a 10ns clock on clk
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Initialize
    dut.rst.value = 1
    dut.rx_valid.value = 0
    dut.rx_data.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Stimulus: Send ITCH message header: msg_type = 0x41 ('A'), len = 0x0011 (17 bytes)
    test_header = [0x41, 0x00, 0x11]
    for byte in test_header:
        dut.rx_data.value = byte
        dut.rx_valid.value = 1
        await RisingEdge(dut.clk)
    dut.rx_valid.value = 0

    # Wait for a few cycles to let output settle
    for _ in range(5):
        await RisingEdge(dut.clk)

    # Check output (for both original and speculative)
    msg_type = dut.msg_type.value.integer
    msg_len = dut.msg_len.value.integer

    if msg_type != 0x41:
        raise TestFailure(f"Expected msg_type 0x41, got {hex(msg_type)}")
    if msg_len != 0x0011:
        raise TestFailure(f"Expected msg_len 0x0011, got {hex(msg_len)}")

    # If output signal is different for module (new_msg vs header_valid)
    if hasattr(dut, "new_msg"):
        assert dut.new_msg.value == 1, "Expected new_msg to be high"
    elif hasattr(dut, "header_valid"):
        assert dut.header_valid.value == 1, "Expected header_valid to be high"
