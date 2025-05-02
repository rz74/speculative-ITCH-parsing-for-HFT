// =============================================
// trade_decoder.v
// =============================================
//
// Description: Speculative streaming Trade decoder.
//              Parses 44-byte ITCH 'P' messages from a raw byte stream.
//
// Author: RZ
// Start Date: 20250501
// Version: 0.1
//
// Changelog
// =============================================
// [20250501-1] RZ: Initial implementation with symbol and price extraction.
// =============================================

// ------------------------------------------------------------------------------------------------
// Protocol Version Note:
// ------------------------------------------------------------------------------------------------
// This decoder implements the Nasdaq ITCH 5.0 Trade ('P') message,
// which is exactly 44 bytes. The final 7 bytes are reserved and not parsed.
// ------------------------------------------------------------------------------------------------
//
// ------------------------------------------------------------------------------------------------
// Architecture Notes:
// ------------------------------------------------------------------------------------------------
// The ITCH "Trade" ('P') message has a fixed length of 44 bytes and is structured as:
//   [ 0     ] = Message Type (ASCII 'P')
//   [ 1–8   ] = Order Reference Number (64-bit)
//   [ 9–12  ] = Shares (32-bit)
//   [13–20  ] = Match ID (64-bit)
//   [21–28  ] = Stock Symbol (8 ASCII, space-padded)
//   [29–32  ] = Price (32-bit)
//   [33–36  ] = Timestamp (32-bit)
//   [37–43  ] = Reserved (ignored)
//
// This decoder consumes a byte-aligned, per-cycle stream of ITCH bytes and speculatively 
// begins parsing at cycle 0. It checks for 'P' on byte 0 and decodes immediately.
// The decoder asserts `trade_internal_valid` after 44 valid cycles only if the type matches.
//
// Inputs:
//   - clk                 : system clock
//   - rst                 : synchronous reset
//   - byte_in[7:0]        : ITCH byte stream (1 byte per cycle)
//   - valid_in            : asserted high when byte_in is valid
//
// Outputs:
//   - trade_internal_valid: one-cycle pulse when a valid Trade message is fully parsed
//   - trade_packet_invalid: asserted if message length overruns unexpectedly
//   - trade_order_ref     : 64-bit order ID
//   - trade_shares        : 32-bit traded shares
//   - trade_match_id      : 64-bit match ID
//   - trade_stock_symbol  : 64-bit ASCII symbol
//   - trade_price         : 32-bit price
//   - trade_timestamp     : 32-bit timestamp
// ------------------------------------------------------------------------------------------------

`timescale 1ns/1ps

module trade_decoder (
    input  logic        clk,
    input  logic        rst,
    input  logic [7:0]  byte_in,
    input  logic        valid_in,

    output logic        trade_internal_valid,
    output logic        trade_packet_invalid,

    output logic [63:0] trade_order_ref,
    output logic [31:0] trade_shares,
    output logic [63:0] trade_match_id,
    output logic [63:0] trade_stock_symbol,
    output logic [31:0] trade_price,
    output logic [31:0] trade_timestamp
);

    parameter MSG_TYPE   = 8'h50;  // ASCII 'P'
    parameter MSG_LENGTH = 44;

    logic [5:0] byte_index;
    logic       is_trade;

    always_ff @(posedge clk) 
    begin
        if (rst) 
        
        begin
            byte_index            <= 0;
            is_trade              <= 0;
            trade_internal_valid  <= 0;
            trade_packet_invalid  <= 0;
            trade_order_ref       <= 0;
            trade_shares          <= 0;
            trade_match_id        <= 0;
            trade_stock_symbol    <= 0;
            trade_price           <= 0;
            trade_timestamp       <= 0;
        end 
        else if (valid_in) 
        begin
            trade_internal_valid <= 0;
            trade_packet_invalid <= 0;

            if (byte_index == 0)
                is_trade <= (byte_in == MSG_TYPE);

            if (is_trade) 
            begin
                case (byte_index)
                    // Order Ref
                    1:  trade_order_ref[63:56] <= byte_in;
                    2:  trade_order_ref[55:48] <= byte_in;
                    3:  trade_order_ref[47:40] <= byte_in;
                    4:  trade_order_ref[39:32] <= byte_in;
                    5:  trade_order_ref[31:24] <= byte_in;
                    6:  trade_order_ref[23:16] <= byte_in;
                    7:  trade_order_ref[15:8]  <= byte_in;
                    8:  trade_order_ref[7:0]   <= byte_in;

                    // Shares
                    9:  trade_shares[31:24] <= byte_in;
                    10: trade_shares[23:16] <= byte_in;
                    11: trade_shares[15:8]  <= byte_in;
                    12: trade_shares[7:0]   <= byte_in;

                    // Match ID
                    13: trade_match_id[63:56] <= byte_in;
                    14: trade_match_id[55:48] <= byte_in;
                    15: trade_match_id[47:40] <= byte_in;
                    16: trade_match_id[39:32] <= byte_in;
                    17: trade_match_id[31:24] <= byte_in;
                    18: trade_match_id[23:16] <= byte_in;
                    19: trade_match_id[15:8]  <= byte_in;
                    20: trade_match_id[7:0]   <= byte_in;

                    // Symbol
                    21: trade_stock_symbol[63:56] <= byte_in;
                    22: trade_stock_symbol[55:48] <= byte_in;
                    23: trade_stock_symbol[47:40] <= byte_in;
                    24: trade_stock_symbol[39:32] <= byte_in;
                    25: trade_stock_symbol[31:24] <= byte_in;
                    26: trade_stock_symbol[23:16] <= byte_in;
                    27: trade_stock_symbol[15:8]  <= byte_in;
                    28: trade_stock_symbol[7:0]   <= byte_in;

                    // Price
                    29: trade_price[31:24] <= byte_in;
                    30: trade_price[23:16] <= byte_in;
                    31: trade_price[15:8]  <= byte_in;
                    32: trade_price[7:0]   <= byte_in;

                    // Timestamp
                    33: trade_timestamp[31:24] <= byte_in;
                    34: trade_timestamp[23:16] <= byte_in;
                    35: trade_timestamp[15:8]  <= byte_in;
                    36: trade_timestamp[7:0]   <= byte_in;

                    // [37–43] Reserved — ignored
                endcase

                if (byte_index == MSG_LENGTH - 1)
                    trade_internal_valid <= 1;
            end

            byte_index <= byte_index + 1;

            if (byte_index >= MSG_LENGTH && is_trade)
                trade_packet_invalid <= 1;
        end

        if (is_trade && (
        (valid_in == 0 && byte_index > 0 && byte_index < MSG_LENGTH) ||
        (byte_index >= MSG_LENGTH)
            ))
            trade_packet_invalid <= 1;

        if (byte_index == MSG_LENGTH) begin
            trade_internal_valid  <= 0;
            trade_packet_invalid  <= 0;
            trade_order_ref       <= 0;
            trade_shares          <= 0;
            trade_match_id        <= 0;
            trade_stock_symbol    <= 0;
            trade_price           <= 0;
            trade_timestamp       <= 0;
            is_trade              <= 0;
            byte_index            <= 0;
        end



    end

endmodule
