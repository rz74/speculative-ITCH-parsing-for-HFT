// -----------------------------------------------------------------------------
// itch_parser.v (Updated with Alternative Optimized Version)
// -----------------------------------------------------------------------------
// This Verilog module extracts the header from an ITCH protocol message,
// consisting of a 1-byte message type and a 2-byte message length.
//
// The active design is simple and reliable, taking 4 clock cycles to process a
// full header. Below the active logic is an alternative 3-cycle version,
// which reacts faster but carries more risk in case of signal glitches.
// -----------------------------------------------------------------------------

module itch_parser (
    input wire clk,               // System clock
    input wire rst,               // Active-high synchronous reset
    input wire [7:0] rx_data,     // Incoming byte stream
    input wire rx_valid,          // Byte valid signal

    output reg [7:0] msg_type,    // Output: message type
    output reg [15:0] msg_len,    // Output: message length
    output reg new_msg            // Output: pulse high for 1 cycle when header is ready
);

    typedef enum logic [2:0] {
        IDLE = 3'd0,
        READ_MSG_LEN1 = 3'd1,
        READ_MSG_LEN2 = 3'd2,
        DONE = 3'd3
    } state_t;

    state_t state, next_state;
    reg [7:0] len_byte1;

    // State update
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Output and logic behavior
    always @(posedge clk) begin
        if (rst) begin
            msg_type <= 8'd0;
            msg_len <= 16'd0;
            len_byte1 <= 8'd0;
            new_msg <= 1'b0;
        end else begin
            new_msg <= 1'b0;

            case (state)
                IDLE: begin
                    if (rx_valid) begin
                        msg_type <= rx_data;
                        next_state <= READ_MSG_LEN1;
                    end else begin
                        next_state <= IDLE;
                    end
                end

                READ_MSG_LEN1: begin
                    if (rx_valid) begin
                        len_byte1 <= rx_data;
                        next_state <= READ_MSG_LEN2;
                    end else begin
                        next_state <= READ_MSG_LEN1;
                    end
                end

                READ_MSG_LEN2: begin
                    if (rx_valid) begin
                        msg_len <= {len_byte1, rx_data};
                        next_state <= DONE;
                    end else begin
                        next_state <= READ_MSG_LEN2;
                    end
                end

                DONE: begin
                    new_msg <= 1'b1;
                    next_state <= IDLE;
                end

                default: begin
                    next_state <= IDLE;
                end
            endcase
        end
    end

/*
    // -------------------------------------------------------------------------
    // ALTERNATIVE: Optimized 3-Cycle Version (Lower Latency, More Risk)
    // -------------------------------------------------------------------------
    // This implementation removes the DONE state and emits `new_msg` in the
    // same cycle the last length byte arrives. Use with caution — ensure
    // downstream logic doesn't miss the single-cycle `new_msg` pulse.

    reg [2:0] byte_count;
    reg [23:0] header_shift;

    always @(posedge clk) begin
        if (rst) begin
            byte_count <= 0;
            header_shift <= 24'd0;
            msg_type <= 8'd0;
            msg_len <= 16'd0;
            new_msg <= 1'b0;
        end else if (rx_valid) begin
            header_shift <= {header_shift[15:0], rx_data};
            byte_count <= byte_count + 1;

            if (byte_count == 2) begin
                msg_type <= header_shift[23:16];
                msg_len <= {header_shift[15:8], header_shift[7:0]};
                new_msg <= 1'b1;
                byte_count <= 0;
            end else begin
                new_msg <= 1'b0;
            end
        end else begin
            new_msg <= 1'b0;
        end
    end
*/

endmodule
