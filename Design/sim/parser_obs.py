import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ReadOnly
from helpers.payload_generator_helper import (
    generate_add_order_payload,
    generate_cancel_order_payload,
    generate_delete_order_payload,
    generate_replace_order_payload,
    generate_executed_order_payload,
    generate_trade_payload,
)
import csv
import os

@cocotb.test()
async def parser_obs(dut):
    """Logs all parser and decoder signals each cycle + prints injected payloads."""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut._log.info("Starting enhanced parser observation test")

    # Clock cycle counter
    cycle = 0
    async def track_cycles():
        nonlocal cycle
        while True:
            await RisingEdge(dut.clk)
            cycle += 1
    cocotb.start_soon(track_cycles())

    # Prepare CSV
    log_path = os.path.join(os.path.dirname(__file__), "parser_obs_log.csv")
    os.makedirs(os.path.dirname(log_path), exist_ok=True)
    log_file = open(log_path, "w", newline="")
    csv_writer = csv.writer(log_file)
    csv_writer.writerow([
        "cycle", "valid_in", "byte_in", "parsed_valid", "parsed_type", "order_ref",
        "add_valid", "add_shares", "add_price",
        "cancel_valid", "cancel_shares",
        "delete_valid", "replace_valid",
        "executed_valid", "trade_valid"
    ])

    # Reset
    dut.rst.value = 1
    dut.valid_in.value = 0
    dut.byte_in.value = 0
    for _ in range(10):
        await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)

    # Helper to inject payload and log it
    async def inject_payload(label, payload: bytes):
        dut._log.info(f"Injecting {label} payload: " + ' '.join(f"{b:02X}" for b in payload))
        for b in payload:
            dut.byte_in.value = b
            dut.valid_in.value = 1
            await RisingEdge(dut.clk)
        dut.valid_in.value = 0
        await RisingEdge(dut.clk)

    # Signal logger
    async def monitor_all_signals():
        while True:
            await RisingEdge(dut.clk)
            await ReadOnly()
            csv_writer.writerow([
                cycle,
                int(dut.valid_in.value),
                int(dut.byte_in.value),
                int(dut.parsed_valid.value),
                int(dut.parsed_type.value),
                int(dut.order_ref.value),

                int(dut.add_internal_valid.value),
                int(dut.add_shares.value),
                int(dut.add_price.value),

                int(dut.cancel_internal_valid.value),
                int(dut.cancel_canceled_shares.value),

                int(dut.delete_internal_valid.value),
                int(dut.replace_internal_valid.value),

                int(dut.executed_internal_valid.value),
                int(dut.trade_internal_valid.value)
            ])

    cocotb.start_soon(monitor_all_signals())

    # Inject ITCH messages
    await inject_payload("ADD", generate_add_order_payload(0))
    await inject_payload("CANCEL", generate_cancel_order_payload(0))
    await inject_payload("DELETE", generate_delete_order_payload(0))
    await inject_payload("REPLACE", generate_replace_order_payload(0))
    await inject_payload("EXECUTED", generate_executed_order_payload(0))
    await inject_payload("TRADE", generate_trade_payload(0))

    # Wait for remaining outputs
    for _ in range(20):
        await RisingEdge(dut.clk)

    log_file.close()
    dut._log.info("Enhanced observation test complete.")
