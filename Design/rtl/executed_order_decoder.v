// =============================================
// executed_order_decoder.v
// =============================================
//
// Description: Speculative streaming Executed Order decoder.
//              Parses 31-byte ITCH 'E' messages from a raw byte stream.
//
// Author: RZ
// Start Date: 20250501
// Version: 0.1
//
// Changelog
// =============================================
// [20250501-1] RZ: Initial implementation based on cancel and replace decoder patterns.
// =============================================

// ------------------------------------------------------------------------------------------------
// Protocol Version Note:
// ------------------------------------------------------------------------------------------------
// The Nasdaq ITCH 5.0 specification defines the Executed Order ('E') message as 31 bytes in total,
// with the first 25 bytes being meaningful and the last 6 bytes reserved. This decoder extracts only
// the relevant fields: order ref, executed shares, match ID, and timestamp. Reserved bytes are ignored.
// ------------------------------------------------------------------------------------------------
//
// ------------------------------------------------------------------------------------------------
// Architecture Notes:
// ------------------------------------------------------------------------------------------------
// The ITCH "Executed Order" ('E') message has a fixed length of 31 bytes and is structured as:
//   [0]      = Message Type (ASCII 'E')
//   [1:8]    = Order Reference Number (64-bit)
//   [9:12]   = Executed Shares (32-bit)
//   [13:20]  = Match ID (64-bit)
//   [21:24]  = Timestamp (32-bit)
//   [25:30]  = Reserved (ignored)
//
// This decoder consumes a byte-aligned, per-cycle stream of ITCH bytes and speculatively 
// begins parsing at cycle 0. It checks for 'E' on byte 0 and begins decoding immediately.
// The decoder asserts `exec_internal_valid` after 31 valid cycles only if the type matches.
//
// Inputs:
//   - clk                : system clock
//   - rst                : synchronous reset
//   - byte_in[7:0]       : ITCH byte stream (1 byte per cycle)
//   - valid_in           : asserted high when byte_in is valid
//
// Outputs:
//   - exec_internal_valid: one-cycle pulse when a valid Executed Order message is fully parsed
//   - exec_packet_invalid: asserted if message length overruns unexpectedly
//   - exec_order_ref     : 64-bit order ID
//   - exec_shares        : 32-bit number of shares executed
//   - exec_match_id      : 64-bit match ID
//   - exec_timestamp     : 32-bit timestamp
// ------------------------------------------------------------------------------------------------

`timescale 1ns/1ps

module executed_order_decoder (
    input  logic        clk,
    input  logic        rst,
    input  logic [7:0]  byte_in,
    input  logic        valid_in,

    output logic        exec_internal_valid,
    output logic        exec_packet_invalid,

    output logic [63:0] exec_order_ref,
    output logic [31:0] exec_shares,
    output logic [63:0] exec_match_id,
    output logic [31:0] exec_timestamp
);

    parameter MSG_TYPE   = 8'h45;  // ASCII 'E'
    parameter MSG_LENGTH = 31;

    logic [5:0] byte_index;
    logic       is_executed_order;

    always_ff @(posedge clk) begin
        if (rst) begin
            byte_index            <= 0;
            is_executed_order     <= 0;
            exec_internal_valid   <= 0;
            exec_packet_invalid   <= 0;
            exec_order_ref        <= 0;
            exec_shares           <= 0;
            exec_match_id         <= 0;
            exec_timestamp        <= 0;
        end else if (valid_in) begin
            exec_internal_valid <= 0;
            exec_packet_invalid <= 0;

            if (byte_index == 0)
                is_executed_order <= (byte_in == MSG_TYPE);

            if (is_executed_order) begin
                case (byte_index)
                    // Order Reference Number
                    1:  exec_order_ref[63:56] <= byte_in;
                    2:  exec_order_ref[55:48] <= byte_in;
                    3:  exec_order_ref[47:40] <= byte_in;
                    4:  exec_order_ref[39:32] <= byte_in;
                    5:  exec_order_ref[31:24] <= byte_in;
                    6:  exec_order_ref[23:16] <= byte_in;
                    7:  exec_order_ref[15:8]  <= byte_in;
                    8:  exec_order_ref[7:0]   <= byte_in;

                    // Shares Executed
                    9:  exec_shares[31:24] <= byte_in;
                    10: exec_shares[23:16] <= byte_in;
                    11: exec_shares[15:8]  <= byte_in;
                    12: exec_shares[7:0]   <= byte_in;

                    // Match Number
                    13: exec_match_id[63:56] <= byte_in;
                    14: exec_match_id[55:48] <= byte_in;
                    15: exec_match_id[47:40] <= byte_in;
                    16: exec_match_id[39:32] <= byte_in;
                    17: exec_match_id[31:24] <= byte_in;
                    18: exec_match_id[23:16] <= byte_in;
                    19: exec_match_id[15:8]  <= byte_in;
                    20: exec_match_id[7:0]   <= byte_in;

                    // Timestamp
                    21: exec_timestamp[31:24] <= byte_in;
                    22: exec_timestamp[23:16] <= byte_in;
                    23: exec_timestamp[15:8]  <= byte_in;
                    24: exec_timestamp[7:0]   <= byte_in;

                    // [25–30] reserved — ignored
                endcase

                if (byte_index == MSG_LENGTH - 1)
                    exec_internal_valid <= 1;
            end

            byte_index <= byte_index + 1;

            if (byte_index >= MSG_LENGTH && is_executed_order)
                exec_packet_invalid <= 1;
        end
    end

endmodule
