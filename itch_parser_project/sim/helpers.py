from cocotb.triggers import RisingEdge, ReadOnly

async def send_header(dut, msg_type, msg_len):
    """Send a full ITCH header over 3 clock cycles."""
    dut.rx_valid.value = 1
    dut.rx_data.value = msg_type
    await RisingEdge(dut.clk)

    dut.rx_data.value = (msg_len >> 8) & 0xFF
    await RisingEdge(dut.clk)

    dut.rx_data.value = msg_len & 0xFF
    await RisingEdge(dut.clk)

    dut.rx_valid.value = 0
    await RisingEdge(dut.clk)

async def wait_for_new_msg(dut, timeout=10):
    """Wait for new_msg to go high within a timeout in clock cycles."""
    for _ in range(timeout):
        await RisingEdge(dut.clk)
        await ReadOnly()  # Wait for signal stabilization
        if dut.new_msg.value == 1:
            return
    raise AssertionError("Timed out waiting for new_msg == 1")

def check_header(dut, expected_type, expected_len):
    """Assert the output header fields."""
    assert dut.msg_type.value == expected_type, f"msg_type mismatch: got {dut.msg_type.value}, expected {expected_type}"
    assert dut.msg_len.value == expected_len, f"msg_len mismatch: got {dut.msg_len.value}, expected {expected_len}"
