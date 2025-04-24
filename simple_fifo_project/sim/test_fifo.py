import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock


@cocotb.test()
async def fifo_basic_test(dut):
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    dut.rst.value = 1
    dut.wr_en.value = 0
    dut.rd_en.value = 0
    dut.din.value = 0
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Write some data
    for i in range(3):
        dut.din.value = i + 1
        dut.wr_en.value = 1
        await RisingEdge(dut.clk)
    dut.wr_en.value = 0

    # Read back data
    for i in range(3):
        dut.rd_en.value = 1
        await RisingEdge(dut.clk)
        assert dut.dout.value == i + 1, f"Expected {i + 1}, got {int(dut.dout.value)}"
    dut.rd_en.value = 0
