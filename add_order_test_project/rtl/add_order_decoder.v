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

// architecture update

// =============================================
// add_order_decoder.v
// =============================================
//
// Description: Module to decode Add Order ('A') messages from ITCH payloads.
// Author: RZ
// Start Date: 20250430
// Version: 0.1
//
// Changelog
// =============================================
// [20250430-1] RZ: Initial speculative streaming implementation per new architecture spec.
// =============================================
`timescale 1ns/1ps

module add_order_decoder (
    input        clk,
    input        rst,
    input  [7:0] byte_in,
    input        valid_in,

    output       internal_valid,
    output       packet_invalid,

    output [63:0] order_ref,
    output        side,
    output [31:0] shares,
    output [63:0] price,
    output [31:0] timestamp,
    output [63:0] misc_data
);

    parameter MSG_TYPE   = 8'h41;   // ASCII 'A'
    parameter MSG_LENGTH = 36;

    reg [5:0] byte_index;
    reg       active;

    reg       internal_valid;
    reg       packet_invalid;
    reg [63:0] order_ref;
    reg        side;
    reg [31:0] shares;
    reg [63:0] price;
    reg [31:0] timestamp;
    reg [63:0] misc_data;

    always @(posedge clk) begin
        if (rst) begin
            byte_index     <= 0;
            active         <= 0;
            internal_valid <= 0;
            packet_invalid <= 0;
            order_ref      <= 0;
            side           <= 0;
            shares         <= 0;
            price          <= 0;
            timestamp      <= 0;
            misc_data      <= 0;
        end else if (valid_in) begin
            internal_valid <= 0;
            packet_invalid <= 0;

            // Cycle 0: speculative match on type
            if (byte_index == 0) begin
                active <= (byte_in == MSG_TYPE);
            end

            // Decode only if active
            if (active) begin
                case (byte_index)
                    1:  order_ref[63:56] <= byte_in;
                    2:  order_ref[55:48] <= byte_in;
                    3:  order_ref[47:40] <= byte_in;
                    4:  order_ref[39:32] <= byte_in;
                    5:  order_ref[31:24] <= byte_in;
                    6:  order_ref[23:16] <= byte_in;
                    7:  order_ref[15:8]  <= byte_in;
                    8:  order_ref[7:0]   <= byte_in;
                    9:  side             <= byte_in[0];
                    10: shares[31:24]   <= byte_in;
                    11: shares[23:16]   <= byte_in;
                    12: shares[15:8]    <= byte_in;
                    13: shares[7:0]     <= byte_in;
                    14: price[63:56]    <= byte_in;
                    15: price[55:48]    <= byte_in;
                    16: price[47:40]    <= byte_in;
                    17: price[39:32]    <= byte_in;
                    18: price[31:24]    <= byte_in;
                    19: price[23:16]    <= byte_in;
                    20: price[15:8]     <= byte_in;
                    21: price[7:0]      <= byte_in;
                    22: timestamp[31:24]<= byte_in;
                    23: timestamp[23:16]<= byte_in;
                    24: timestamp[15:8] <= byte_in;
                    25: timestamp[7:0]  <= byte_in;
                    26: misc_data[63:56]<= byte_in;
                    27: misc_data[55:48]<= byte_in;
                    28: misc_data[47:40]<= byte_in;
                    29: misc_data[39:32]<= byte_in;
                    30: misc_data[31:24]<= byte_in;
                    31: misc_data[23:16]<= byte_in;
                    32: misc_data[15:8] <= byte_in;
                    33: misc_data[7:0]  <= byte_in;
                    default: ; // no-op
                endcase

                if (byte_index == MSG_LENGTH - 1)
                    internal_valid <= 1;
            end

            // Increment only if active
            if (active) begin
                byte_index <= byte_index + 1;
            end else begin
                byte_index <= 0; // reset index if inactive
            end

            if (byte_index >= MSG_LENGTH && active)
                packet_invalid <= 1;
        end
    end

endmodule
