import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock
from helpers import send_header, check_header
import random

@cocotb.test()
async def test_basic_header(dut):
    """Test a single valid header sequence."""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())  # Start clock
    dut.rst.value = 1                                           # Apply reset
    dut.rx_valid.value = 0                                      # Default no data
    dut.rx_data.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst.value = 0                                           # Deassert reset

    # Send header: msg_type=0x41, msg_len=0x0011
    await send_header(dut, 0x41, 0x0011)

    # Allow time for FSM to reach DONE and assert output
    for _ in range(3):
        await RisingEdge(dut.clk)

    # Check results
    check_header(dut, 0x41, 0x0011)

@cocotb.test()
async def test_multiple_headers(dut):
    """Send two valid headers in succession."""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut.rst.value = 1
    dut.rx_valid.value = 0
    dut.rx_data.value = 0
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    headers = [(0x10, 0x0003), (0x99, 0xABCD)]

    for msg_type, msg_len in headers:
        await send_header(dut, msg_type, msg_len)
        for _ in range(3):
            await RisingEdge(dut.clk)
        check_header(dut, msg_type, msg_len)

@cocotb.test()
async def test_random_headers(dut):
    """Test several randomized headers."""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut.rst.value = 1
    dut.rx_valid.value = 0
    dut.rx_data.value = 0
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    for _ in range(5):
        msg_type = random.randint(0, 255)
        msg_len = random.randint(0, 0xFFFF)
        await send_header(dut, msg_type, msg_len)
        for _ in range(3):
            await RisingEdge(dut.clk)
        check_header(dut, msg_type, msg_len)

@cocotb.test()
async def test_reset_midstream(dut):
    """Reset in the middle of a message to see if parser recovers."""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut.rst.value = 0
    dut.rx_valid.value = 1
    dut.rx_data.value = 0x55
    await RisingEdge(dut.clk)

    dut.rx_data.value = 0xAA
    await RisingEdge(dut.clk)

    dut.rst.value = 1  # Reset mid-stream
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    await send_header(dut, 0x42, 0x0021)
    for _ in range(3):
        await RisingEdge(dut.clk)
    check_header(dut, 0x42, 0x0021)
