import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock

@cocotb.test()
async def test_payload_parser(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    payload = bytearray(64)
    payload[0] = ord('A')
    payload[1:9] = (0x12345678ABCDEF00).to_bytes(8, byteorder='big')
    payload[9] = ord('B')
    payload[10:14] = (1000).to_bytes(4, byteorder='big')
    payload[14:22] = b"GOOG    "  # 8-byte stock symbol
    payload[22:26] = (100000).to_bytes(4, byteorder='big')

    dut.in_valid.value = 1
    dut.msg_type.value = ord('A')
    dut.payload.value = int.from_bytes(payload, byteorder='big')
    await RisingEdge(dut.clk)
    dut.in_valid.value = 0

    for _ in range(5):
        await RisingEdge(dut.clk)

    cocotb.log.info(f"Decoded Order Ref: 0x{dut.order_ref.value.integer:016X}")
    cocotb.log.info(f"Buy/Sell: {'Sell' if dut.buy_sell.value else 'Buy'}")
    cocotb.log.info(f"Shares: {dut.shares.value.integer}")
    cocotb.log.info(f"Price: {dut.price.value.integer}")
    stock_bytes = dut.stock_symbol.value.integer.to_bytes(8, 'big')
    cocotb.log.info(f"Stock Symbol: {stock_bytes.decode(errors='ignore')}")