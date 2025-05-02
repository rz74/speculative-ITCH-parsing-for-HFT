import cocotb
from cocotb.triggers import RisingEdge

@cocotb.test()
async def sanity_check(dut):
    dut._log.info("Starting sanity check")

    # Reset
    dut.rst.value = 1
    dut.valid_in.value = 0
    dut.byte_in.value = 0
    for _ in range(3):
        await RisingEdge(dut.clk)
    dut.rst.value = 0
    dut._log.info("Reset complete")

    # Wait without doing anything
    for _ in range(5):
        await RisingEdge(dut.clk)

    dut._log.info("Sanity check passed (no crash)")
