
# HFT FPGA Payload Parser — Module Requirements Specification

This document outlines the detailed design requirements for each major RTL module in the speculative ITCH parser pipeline.

---

## Module: `header_parser`

**Purpose:**  
Parse incoming TCP byte stream and detect the start of a new ITCH message.

**Inputs:**
- `clk`: System clock
- `rst_n`: Active-low reset
- `tcp_payload_in[7:0]`: Incoming byte stream
- `tcp_byte_valid_in`: Input valid strobe

**Outputs:**
- `start_flag`: 1-cycle pulse at the start of each message
- `payload_out[7:0]`: Forwarded payload byte
- `payload_valid_out`: Indicates payload_out is valid

**Behavior:**
- Latch `tcp_payload_in` into `payload_out` on valid input.
- Assert `payload_valid_out = 1` when input is valid.
- Pulse `start_flag = 1` on first byte of message only.
- Drop `payload_valid_out` 1 clk after `tcp_byte_valid_in` falls.

**Timing:** 1-cycle latency, fully pipelined  
**Reset:** All outputs cleared on `rst_n = 0`

---

## Module: `add_order_decoder`

**Purpose:**  
Decode Add Order ('A') messages from the ITCH payload.

**Inputs:**
- `clk`, `rst_n`
- `payload_in[7:0]`
- `payload_valid_in`
- `start_flag`

**Outputs:**
- `order_ref[63:0]`
- `buy_sell[0:0]`
- `shares[31:0]`
- `stock_symbol[63:0]`
- `price[32:0]`
- `add_order_decoded` (1-cycle pulse)

**Behavior:**
- Start on `start_flag = 1`.
- Decode fixed fields as bytes arrive.
- Assert `add_order_decoded` exactly one cycle post last field.

**Timing:** Pipelined, speculative  
**Reset:** All fields cleared on reset

---

## Module: `cancel_order_decoder`

**Purpose:**  
Decode Cancel Order ('X') messages.

**Inputs/Outputs:** As above.  
**Behavior:**  
- Decode `order_ref`, `cancel_shares`
- Assert `cancel_order_decoded` after parse

**Timing:** Fixed-length, speculative  
**Reset:** Clears all fields

---

## Module: `delete_order_decoder`

**Purpose:**  
Decode Delete Order ('D') messages.

**Behavior:**  
- Extract `order_ref` only
- Pulse `delete_order_decoded` on success

**Timing:** Fast, fixed-length  
**Reset:** All outputs cleared

---

## Module: `replace_order_decoder`

**Purpose:**  
Decode Replace Order ('U') messages.

**Outputs:**
- `original_order_ref[63:0]`
- `new_order_ref[63:0]`
- `shares[31:0]`
- `price[32:0]`
- `replace_order_decoded`

**Behavior:**  
- Start on `start_flag`, parse fields on valid payloads
- Raise pulse when decode completes

**Timing:** Pipelined, speculative  
**Reset:** Clears state

---

## Module: `length_validator`

**Purpose:**  
Parallel message length validation.

**Inputs:**
- `clk`, `rst_n`
- `payload_valid_in`
- `start_flag`

**Output:**
- `valid_flag`

**Behavior:**
- Begin counting on `start_flag`
- Compare observed byte count to expected length
- Raise `valid_flag` only when message length is correct
- Suppress `valid_flag` on underrun or overrun

**Timing:** Runs in parallel with decoder  
**Reset:** Resets counter and flag on `rst_n = 0`

---

**Note:**  
Each decoder operates speculatively. Only valid, complete messages are committed downstream by checking both decoder_done and `valid_flag`.
