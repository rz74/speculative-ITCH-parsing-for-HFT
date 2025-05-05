import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.utils import get_sim_time

from helpers.reset_helper import reset_dut
from helpers.recorder import record_all_internal_valids, get_recorded_log
from helpers.full_workload_helper import run_full_payload_workload
from helpers.injection_helper import inject_payload
from helpers.compare_helper import compare_against_expected, generate_expected_events_with_fields, generate_expected_events_from_schedule
from sim_config import SIM_CLK_PERIOD_NS, MSG_SEQUENCE, SIM_CYCLES, RESET_CYCLES
from ITCH_config import MSG_LENGTHS, SIM_HEADERS
import csv



@cocotb.test()
async def test_full_add_cancel_workload(dut):
    dut._log.info("Starting full workload test")

    # Start the clock
    cocotb.start_soon(Clock(dut.clk, SIM_CLK_PERIOD_NS, units="ns").start())

    # Reset DUT
    await reset_dut(dut)

    # Generate message stream and expected outputs (includes parsed fields)
    result = run_full_payload_workload(MSG_SEQUENCE)
    full_stream = result["full_stream"]
    injection_schedule = result["injection_schedule"]
    expected_events = generate_expected_events_from_schedule(injection_schedule)


    # Start recording before any injection
    cocotb.start_soon(record_all_internal_valids(dut, total_cycles=SIM_CYCLES))

    # Inject full byte stream serially
    for byte in full_stream:
        dut.valid_in.value = 1
        dut.byte_in.value = byte
        await RisingEdge(dut.clk)
    dut.valid_in.value = 0

    # Let the system run a bit after last injection
    for _ in range(20):
        await RisingEdge(dut.clk)

    # Retrieve and compare recorded results
    recorded_log = get_recorded_log()



    # Write recorded log to CSV
    with open("recorded_log.csv", "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=SIM_HEADERS)
        writer.writeheader()
        for cycle in sorted(recorded_log):
            row = {"cycle": cycle}
            row.update(recorded_log[cycle])
            writer.writerow(row)

    # Write expected events to CSV
    with open("expected_events.csv", "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=SIM_HEADERS)
        writer.writeheader()
        for event in expected_events:
            writer.writerow(event)

    compare_against_expected(recorded_log, expected_events)
