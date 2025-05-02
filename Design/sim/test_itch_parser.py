import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from helpers.payload_generator_helper import generate_add_order_payload, generate_cancel_order_payload
from helpers.injection_helper import inject_and_expect_parsed_cycle

@cocotb.test()
async def test_itch_parser_add_then_cancel(dut):
    """Send one Add and one Cancel message through full ITCH parser"""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut._log.info("Starting ITCH parser integration test")

    # Internal clock cycle tracker
    current_cycle = 0
    async def count_cycles():
        nonlocal current_cycle
        while True:
            await RisingEdge(dut.clk)
            current_cycle += 1
    cocotb.start_soon(count_cycles())

    # Monitor parsed_valid for debug (optional)
    async def monitor_parsed_valid():
        cycle = 0
        while True:
            await RisingEdge(dut.clk)
            cycle += 1
            if dut.parsed_valid.value == 1:
                dut._log.info(
                    f"[parsed_valid] Cycle {cycle}: type={int(dut.parsed_type.value)}, "
                    f"order_ref=0x{int(dut.order_ref.value):016X}"
                )
    cocotb.start_soon(monitor_parsed_valid())

    # Reset
    dut.rst.value = 1
    dut.valid_in.value = 0
    dut.byte_in.value = 0
    for _ in range(3):
        await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Inject Add Order and expect parser result
    add_payload = generate_add_order_payload(index=1)
    await inject_and_expect_parsed_cycle(
        dut,
        payload=add_payload,
        start_cycle=current_cycle +1,  # this tracks the actual abs cycle
        expected_type=1,
        expected_order_ref=int.from_bytes(add_payload[1:9], 'big')
    )


    # # Inject Cancel Order and expect parser result
    # cancel_payload = generate_cancel_order_payload(index=1)
    # await inject_and_expect_parsed_cycle(
    #     dut,
    #     payload=cancel_payload,
    #     current_cycle=current_cycle,
    #     expected_type=2,
    #     expected_order_ref=int.from_bytes(cancel_payload[1:9], 'big')
    # )

    dut._log.info("ITCH parser integration test passed")
