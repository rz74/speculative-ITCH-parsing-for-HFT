import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def test_watchdog_triggers_on_stall(dut):
    """
    Test that watchdog triggers when byte_index stops incrementing
    while valid_in and is_active stay high.
    """
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    dut.rst.value = 1
    dut.valid_in.value = 0
    dut.is_active.value = 0
    dut.byte_index.value = 0
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Simulate a valid packet progression (should not trigger)
    dut.is_active.value = 1
    for i in range(5):
        dut.valid_in.value = 1
        dut.byte_index.value = i
        await RisingEdge(dut.clk)

    # Hold byte_index constant to simulate stall
    dut.byte_index.value = 4  # Stalled index
    for _ in range(dut.STALL_CYCLES.value):
        await RisingEdge(dut.clk)

    # Wait one more cycle to allow nonblocking assignment to propagate
    await RisingEdge(dut.clk)

    assert dut.stuck_flag.value == 1, "Watchdog did not trigger on stall"


@cocotb.test()
async def test_watchdog_does_not_trigger_on_good_data(dut):
    """
    Test that watchdog does not trigger when byte_index progresses normally.
    """
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    dut.rst.value = 1
    dut.valid_in.value = 0
    dut.is_active.value = 0
    dut.byte_index.value = 0
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Simulate normal valid sequence
    dut.is_active.value = 1
    for i in range(10):
        dut.valid_in.value = 1
        dut.byte_index.value = i
        await RisingEdge(dut.clk)

    assert dut.stuck_flag.value == 0, "Watchdog falsely triggered on valid data"
