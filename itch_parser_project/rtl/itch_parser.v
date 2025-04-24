module itch_parser (
    input wire clk,               // System clock
    input wire rst,               // Active-high synchronous reset
    input wire [7:0] rx_data,     // Incoming byte (from ITCH stream)
    input wire rx_valid,          // Indicates rx_data is valid

    output reg [7:0] msg_type,    // Parsed message type (1st byte of header)
    output reg [15:0] msg_len,    // Parsed message length (2nd & 3rd bytes)
    output reg new_msg            // High for 1 cycle when a full header is parsed
);

    // Define FSM states using a typedef enum
    typedef enum logic [2:0] {
        IDLE = 3'd0,              // Waiting for start of new message
        READ_MSG_LEN1 = 3'd1,     // Received msg_type, waiting for length byte 1
        READ_MSG_LEN2 = 3'd2,     // Received length byte 1, waiting for length byte 2
        DONE = 3'd3               // Full header received
    } state_t;

    // FSM state registers
    state_t state, next_state;

    // Temporary storage for the first byte of length field
    reg [7:0] len_byte1;

    // State register logic: update current state on rising edge of clk
    always @(posedge clk) begin
        if (rst)
            state <= IDLE;        // Reset to IDLE state
        else
            state <= next_state;  // Transition to computed next state
    end

    // Combinational block: defines the FSM's next state based on inputs and current state
    always @(*) begin
        next_state = state;       // Default is to stay in current state
        case (state)
            IDLE: if (rx_valid) next_state = READ_MSG_LEN1;
            READ_MSG_LEN1: if (rx_valid) next_state = READ_MSG_LEN2;
            READ_MSG_LEN2: if (rx_valid) next_state = DONE;
            DONE: next_state = IDLE;
        endcase
    end

    // Output and behavior logic (sequential)
    always @(posedge clk) begin
        if (rst) begin
            msg_type <= 8'd0;         // Clear outputs on reset
            msg_len <= 16'd0;
            len_byte1 <= 8'd0;
            new_msg <= 1'b0;
        end else begin
            new_msg <= 1'b0;          // Default: no new message

            case (state)
                IDLE: begin
                    if (rx_valid)
                        msg_type <= rx_data;  // Capture message type
                end

                READ_MSG_LEN1: begin
                    if (rx_valid)
                        len_byte1 <= rx_data; // Capture high byte of msg_len
                end

                READ_MSG_LEN2: begin
                    if (rx_valid)
                        msg_len <= {len_byte1, rx_data}; // Combine to form msg_len
                end

                DONE: begin
                    new_msg <= 1'b1;   // Signal that a full header was parsed
                end
            endcase
        end
    end

    // Waveform dumping block for simulation only (ignored in synthesis)
    `ifdef COCOTB_SIM
    initial begin
        $dumpfile("dump.vcd");         // Output VCD file name
        $dumpvars(0, itch_parser);     // Dump all signals in this module
    end
    `endif

endmodule
