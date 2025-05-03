import cocotb
from helpers.payload_generator_helper import generate_payload_by_type
from helpers.injection_helper import inject_payload
from helpers.assertion_helper import assert_valid_wrapper
from sim_config import SIM_CLK_PERIOD_NS
from cocotb.utils import get_sim_time

async def handle_single_message(dut, msg_type, mode='set'):
    # Get simulation time before injection
    sim_time_start = get_sim_time('ns')
    abs_cycle_start = sim_time_start // SIM_CLK_PERIOD_NS
    dut._log.info(f"[{msg_type.upper()}] Injecting at sim_time={sim_time_start}ns (abs_cycle={abs_cycle_start})")

    # Generate payload and inject
    payload = generate_payload_by_type(msg_type, mode)
    await inject_payload(dut, payload)

    # Assert valid at expected cycle
    await assert_valid_wrapper(dut, msg_type, abs_cycle_start)
