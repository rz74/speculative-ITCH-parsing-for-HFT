from cocotb.triggers import RisingEdge

async def send_header(dut, msg_type, msg_len):
    """Send a full ITCH header over 3 clock cycles."""
    dut.rx_valid.value = 1
    dut.rx_data.value = msg_type
    await RisingEdge(dut.clk)

    dut.rx_data.value = (msg_len >> 8) & 0xFF
    await RisingEdge(dut.clk)

    dut.rx_data.value = msg_len & 0xFF
    await RisingEdge(dut.clk)

    dut.rx_valid.value = 0  # Stop sending
    await RisingEdge(dut.clk)

def check_header(dut, expected_type, expected_len):
    """Assert the output header fields and new_msg pulse."""
    assert dut.msg_type.value == expected_type, f"msg_type mismatch: got {dut.msg_type.value}, expected {expected_type}"
    assert dut.msg_len.value == expected_len, f"msg_len mismatch: got {dut.msg_len.value}, expected {expected_len}"
    assert dut.new_msg.value == 1, "new_msg signal not asserted"
