import cocotb
# from cocotb.clock import Clock
# from cocotb.triggers import RisingEdge
from cocotb.utils import get_sim_time

# from helpers.payload_generator_helper import generate_add_payload, generate_cancel_payload
# from helpers.injection_helper import inject_payload
# from helpers.assertion_helper import (
#     assert_add_valid_at_cycle,
#     assert_cancel_valid_at_cycle,
# )

# from sim_config import SIM_CLK_PERIOD_NS
# Global cycle counter
# cycle_count = 0
# removed to avoid circular dependency with helpers and use a cleaner approach
# with sim config that sets period and all modules use sim time and period

# Clock cycle tracking coroutine
# async def count_clock_cycles(dut):
#     global cycle_count
#     cycle_count = 0  # Reset right here at coroutine start
#     dut._log.info(f"[DEBUG] Entered count_clock_cycles at {get_sim_time('ns')}ns")
#     while True:
#         await RisingEdge(dut.clk)
#         cycle_count += 1

from cocotb import test
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from helpers.handle_single_message import handle_single_message
from sim_config import SIM_CLK_PERIOD_NS   

@test()
async def test_add_then_cancel_no_pause(dut):
    cocotb.start_soon(Clock(dut.clk, SIM_CLK_PERIOD_NS, units="ns").start())

    # Reset
    dut.rst.value = 1
    dut.valid_in.value = 0
    dut.byte_in.value = 0
    for _ in range(3):
        await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Unified message flow
    await handle_single_message(dut, 'add', mode='set')
    await handle_single_message(dut, 'cancel', mode='set')
    await handle_single_message(dut, 'add', mode='set')
    await handle_single_message(dut, 'add', mode='set')
    await handle_single_message(dut, 'cancel', mode='set')
    await handle_single_message(dut, 'cancel', mode='set')
