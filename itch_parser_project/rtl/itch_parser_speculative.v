// -----------------------------------------------------------------------------
// itch_parser_speculative.v
// -----------------------------------------------------------------------------
// This Verilog module implements a speculative ITCH header parser.
// It begins dispatching the message type to downstream logic immediately,
// before the full length is known. If the message turns out to be invalid,
// the downstream logic is expected to discard any buffered data.
//
// This design is optimized for high-throughput systems like FPGA HFT engines.
// -----------------------------------------------------------------------------

module itch_parser_speculative (
    input wire clk,
    input wire rst,
    input wire [7:0] rx_data,
    input wire rx_valid,

    output reg [7:0] msg_type,     // Sent immediately to downstream
    output reg [15:0] msg_len,     // Final message length (after 3rd byte)
    output reg header_valid        // Raised one cycle after full header is parsed
);

    // Shift register style implementation
    reg [1:0] byte_count;          // Counts received header bytes (0 to 2)
    reg [7:0] len_byte1;

    always @(posedge clk) begin
        if (rst) begin
            byte_count <= 0;
            msg_type <= 8'd0;
            msg_len <= 16'd0;
            len_byte1 <= 8'd0;
            header_valid <= 1'b0;
        end else begin
            header_valid <= 1'b0; // default

            if (rx_valid) begin
                case (byte_count)
                    0: begin
                        msg_type <= rx_data;  // Immediately dispatch msg_type
                        byte_count <= 1;
                    end
                    1: begin
                        len_byte1 <= rx_data;  // Store first length byte
                        byte_count <= 2;
                    end
                    2: begin
                        msg_len <= {len_byte1, rx_data}; // Combine full length
                        header_valid <= 1'b1;            // Header is now valid
                        byte_count <= 0;                 // Reset for next message
                    end
                    default: byte_count <= 0;
                endcase
            end
        end
    end

endmodule
