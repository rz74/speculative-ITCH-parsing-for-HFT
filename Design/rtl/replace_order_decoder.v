// =============================================
// replace_order_decoder.v
// =============================================
//
// Description: Speculative streaming Replace Order decoder.
//              Parses 25-byte ITCH 'U' messages from a raw byte stream.
//
// Author: RZ
// Start Date: 20250428
// Version: 0.3
//
// Changelog
// =============================================
// [20250428-1] RZ: Initial Replace Order decoder implementation.
// [20250428-2] RZ: Added valid_flag signal
// [20250501-1] RZ: Initial implementation modeled after add_order_decoder module under new architecture.
// =============================================

// ------------------------------------------------------------------------------------------------
// Protocol Version Note:
// ------------------------------------------------------------------------------------------------
// While some ITCH variants or academic simulations include stock symbol or participant metadata 
// (e.g., total 35 bytes), the Nasdaq ITCH 5.0 spec defines the Replace Order ('U') message as 
// exactly 25 bytes: 1-byte type, 2x 64-bit refs, 32-bit shares, and 32-bit price.
// This decoder implements the 25-byte ITCH 5.0 version.
// ------------------------------------------------------------------------------------------------
//
// ------------------------------------------------------------------------------------------------
// Architecture Notes:
// ------------------------------------------------------------------------------------------------
// The ITCH "Replace Order" ('U') message has a fixed length of 25 bytes and is structured as:
//   [0]      = Message Type (ASCII 'U')
//   [1:8]    = Original Order Reference Number (64-bit)
//   [9:16]   = New Order Reference Number (64-bit)
//   [17:20]  = Updated Shares (32-bit)
//   [21:24]  = Updated Price (32-bit)
//
// This decoder consumes a byte-aligned, per-cycle stream of ITCH bytes and speculatively 
// begins parsing at cycle 0. On cycle 0, it captures the message type and immediately decodes
// byte 1 as `old_order_ref[63:56]`. Parallel validation confirms whether the message is of type 'U'.
// The decoder asserts `internal_valid` after 25 valid cycles only if the type matches.
//
// Inputs:
//   - clk                 : system clock
//   - rst                 : synchronous reset
//   - byte_in[7:0]        : ITCH byte stream (1 byte per cycle)
//   - valid_in            : asserted high when byte_in is valid
//
// Outputs:
//   - internal_valid      : one-cycle pulse when a valid Replace Order message is fully parsed
//   - packet_invalid      : asserted if message length overruns unexpectedly
//   - old_order_ref       : 64-bit original order reference
//   - new_order_ref       : 64-bit new order reference
//   - replace_shares      : 32-bit updated shares
//   - replace_price       : 32-bit updated price
// ------------------------------------------------------------------------------------------------

`timescale 1ns/1ps

module replace_order_decoder (
    input  logic        clk,
    input  logic        rst,
    input  logic [7:0]  byte_in,
    input  logic        valid_in,

    output logic        replace_internal_valid,
    output logic        replace_packet_invalid,

    output logic [63:0] replace_old_order_ref,
    output logic [63:0] replace_new_order_ref,
    output logic [31:0] replace_shares,
    output logic [31:0] replace_price
);

    parameter MSG_TYPE   = 8'h55;  // ASCII 'U'
    parameter MSG_LENGTH = 25;

    logic [5:0] byte_index;
    logic       is_replace_order;

    always_ff @(posedge clk) 
    begin
        if (rst) 
        begin
            byte_index              <= 0;
            is_replace_order        <= 0;
            replace_internal_valid  <= 0;
            replace_packet_invalid  <= 0;
            replace_old_order_ref   <= 0;
            replace_new_order_ref   <= 0;
            replace_shares          <= 0;
            replace_price           <= 0;
        end 
        else if (valid_in) 
        begin
            replace_internal_valid <= 0;
            replace_packet_invalid <= 0;

            if (byte_index == 0)
                is_replace_order <= (byte_in == MSG_TYPE);

            if (is_replace_order) 
            begin
                case (byte_index)
                    // Old Order Ref
                    1:  replace_old_order_ref[63:56] <= byte_in;
                    2:  replace_old_order_ref[55:48] <= byte_in;
                    3:  replace_old_order_ref[47:40] <= byte_in;
                    4:  replace_old_order_ref[39:32] <= byte_in;
                    5:  replace_old_order_ref[31:24] <= byte_in;
                    6:  replace_old_order_ref[23:16] <= byte_in;
                    7:  replace_old_order_ref[15:8]  <= byte_in;
                    8:  replace_old_order_ref[7:0]   <= byte_in;

                    // New Order Ref
                    9:  replace_new_order_ref[63:56] <= byte_in;
                    10: replace_new_order_ref[55:48] <= byte_in;
                    11: replace_new_order_ref[47:40] <= byte_in;
                    12: replace_new_order_ref[39:32] <= byte_in;
                    13: replace_new_order_ref[31:24] <= byte_in;
                    14: replace_new_order_ref[23:16] <= byte_in;
                    15: replace_new_order_ref[15:8]  <= byte_in;
                    16: replace_new_order_ref[7:0]   <= byte_in;

                    // Shares
                    17: replace_shares[31:24] <= byte_in;
                    18: replace_shares[23:16] <= byte_in;
                    19: replace_shares[15:8]  <= byte_in;
                    20: replace_shares[7:0]   <= byte_in;

                    // Price
                    21: replace_price[31:24] <= byte_in;
                    22: replace_price[23:16] <= byte_in;
                    23: replace_price[15:8]  <= byte_in;
                    24: replace_price[7:0]   <= byte_in;
                endcase

                if (byte_index == MSG_LENGTH - 1)
                    replace_internal_valid <= 1;
            end

            byte_index <= byte_index + 1;

            if (byte_index >= MSG_LENGTH && is_replace_order)
                replace_packet_invalid <= 1;
        end

        if (is_replace_order && (
        (valid_in == 0 && byte_index > 0 && byte_index < MSG_LENGTH) ||
        (byte_index >= MSG_LENGTH)
        ))
        replace_packet_invalid <= 1;

        if (byte_index == MSG_LENGTH) 
        begin
            replace_internal_valid   <= 0;
            replace_packet_invalid   <= 0;
            replace_old_order_ref    <= 0;
            replace_new_order_ref    <= 0;
            replace_shares           <= 0;
            replace_price            <= 0;
            is_replace_order         <= 0;
            byte_index               <= 0;
        end

    end

endmodule

