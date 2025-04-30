// =============================================
// add_order_decoder.v
// =============================================
//
// Description: Speculative streaming Add Order decoder.
//              Uses byte stream interface, decodes live while monitoring
//              externally validated message length.
// Author: RZ
// Start Date: 04292025
// Version: 0.5
//
// Changelog
// =============================================
// [20250427-1] RZ: Initial wide-interface implementation.
// [20250429-1] RZ: Refactored for pipelined byte-stream interface.
// [20250429-2] RZ: Removed buffering; decoding is immediate per cycle.
// [20250430-1] RZ: Dropped wide interface and adopted streaming byte-by-byte interface only.
// [20250430-2] RZ: Added speculative length-aware termination logic.
// =============================================

module add_order_decoder (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [7:0]  payload_in,
    input  wire        payload_valid_in,
    input  wire        start_flag,
    input  wire [5:0]  expected_length,    // from parallel length validator
    input  wire        length_valid,       // high when expected_length is valid

    output reg         add_order_decoded,
    output reg [63:0]  order_ref,
    output reg         buy_sell,
    output reg [31:0]  shares,
    output reg [63:0]  stock_symbol,
    output reg [31:0]  price
);

    reg [5:0] byte_index;
    reg [5:0] length_latched;
    reg       length_latched_valid;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            byte_index <= 0;
            order_ref <= 0;
            buy_sell <= 0;
            shares <= 0;
            stock_symbol <= 0;
            price <= 0;
            add_order_decoded <= 0;
            length_latched <= 0;
            length_latched_valid <= 0;
        end else begin
            add_order_decoded <= 0;

            // latch length if valid
            if (length_valid)
                length_latched <= expected_length;

            if (start_flag) begin
                byte_index <= 0;
                length_latched_valid <= 0;
            end

            if (payload_valid_in) begin
                case (byte_index)
                    1:  order_ref[63:56] <= payload_in;
                    2:  order_ref[55:48] <= payload_in;
                    3:  order_ref[47:40] <= payload_in;
                    4:  order_ref[39:32] <= payload_in;
                    5:  order_ref[31:24] <= payload_in;
                    6:  order_ref[23:16] <= payload_in;
                    7:  order_ref[15:8]  <= payload_in;
                    8:  order_ref[7:0]   <= payload_in;
                    9:  buy_sell         <= (payload_in == "B");
                    10: shares[31:24]    <= payload_in;
                    11: shares[23:16]    <= payload_in;
                    12: shares[15:8]     <= payload_in;
                    13: shares[7:0]      <= payload_in;
                    14: stock_symbol[63:56] <= payload_in;
                    15: stock_symbol[55:48] <= payload_in;
                    16: stock_symbol[47:40] <= payload_in;
                    17: stock_symbol[39:32] <= payload_in;
                    18: stock_symbol[31:24] <= payload_in;
                    19: stock_symbol[23:16] <= payload_in;
                    20: stock_symbol[15:8]  <= payload_in;
                    21: stock_symbol[7:0]   <= payload_in;
                    22: price[31:24]     <= payload_in;
                    23: price[23:16]     <= payload_in;
                    24: price[15:8]      <= payload_in;
                    25: price[7:0]       <= payload_in;
                endcase

                // increment index
                byte_index <= byte_index + 1;

                // if length was latched and we're at final byte
                if (length_latched_valid && (byte_index == length_latched - 1)) begin
                    add_order_decoded <= 1;
                end
            end

            // once length_valid comes in during decoding
            if (!length_latched_valid && length_valid)
                length_latched_valid <= 1;
        end
    end

endmodule
