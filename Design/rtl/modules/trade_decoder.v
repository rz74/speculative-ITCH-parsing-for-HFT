// =============================================
// trade_decoder.v
// =============================================
//
// Description: Speculative streaming Trade decoder.
//              Parses 44-byte ITCH 'P' messages from a raw byte stream.
//
// Author: RZ
// Start Date: 20250501
// Version: 0.2
//
// Changelog
// =============================================
// [20250501-1] RZ: Initial implementation with symbol and price extraction.
// [20250501-2] RZ: Added self disable and zeroing of signals after message parsing completion.
// [20250502-1] RZ: Updated msg structure
// =============================================
// ------------------------------------------------------------------------------------------------
// Protocol Version Note:
// ------------------------------------------------------------------------------------------------
// This decoder implements the streamlined ITCH 5.0 Trade ('P') message used in real-world HFT
// parser designs. It excludes upstream metadata such as tracking numbers, locate codes, and
// participant info.
//
// The Trade message is exactly 40 bytes and is structured as follows:
//   [0]      = Message Type (ASCII 'P')
//   [1:6]    = Timestamp (48-bit, nanoseconds since midnight)
//   [7:14]   = Order Reference Number (64-bit)
//   [15]     = Buy/Sell Indicator (ASCII 'B' or 'S')
//   [16:19]  = Number of Shares (32-bit)
//   [20:27]  = Stock Symbol (8 ASCII characters, space-padded)
//   [28:31]  = Price (32-bit, fixed-point with 4 implied decimals)
//   [32:39]  = Match ID (64-bit)
//
// This form omits any reserved bytes. It reflects the stripped-down format used in production
// ITCH parser modules that operate directly on TCP-processed byte streams.
// ------------------------------------------------------------------------------------------------
//
// ------------------------------------------------------------------------------------------------
// Architecture Notes:
// ------------------------------------------------------------------------------------------------
// The decoder consumes a byte-aligned ITCH byte stream and begins speculative parsing at byte 0.
// After detecting a 'P' on byte 0, it continues decoding the remaining 39 bytes sequentially.
//
// The decoder asserts `trade_internal_valid` on the final byte (cycle 39) only if the message type
// matched and all required bytes were seen in order.
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
//   - trade_timestamp     : 48-bit timestamp (ns since midnight)
//   - trade_order_ref     : 64-bit order ID
//   - trade_side          : 8-bit ASCII side ('B' or 'S') ===> parsed to buy = 0 and sell = 1
//   - trade_shares        : 32-bit share count
//   - trade_stock_symbol  : 64-bit symbol (8 ASCII characters)
//   - trade_price         : 32-bit price (1/10,000 dollar units)
//   - trade_match_id      : 64-bit match ID
// ------------------------------------------------------------------------------------------------

module trade_decoder (
    input  logic        clk,
    input  logic        rst,
    input  logic [7:0]  byte_in,
    input  logic        valid_in,

    output logic        trade_internal_valid,
    output logic        trade_packet_invalid,

    output logic [47:0] trade_timestamp,
    output logic [63:0] trade_order_ref,
    output logic [7:0]  trade_side,
    output logic [31:0] trade_shares,
    output logic [63:0] trade_stock_symbol,
    output logic [31:0] trade_price,
    output logic [63:0] trade_match_id
);

    parameter MSG_TYPE   = 8'h50;  // ASCII 'P'
    parameter MSG_LENGTH = 40;

    `include "macros/itch_len.vh"
    `include "macros/itch_suppression.vh"

    // function automatic logic [5:0] itch_length(input logic [7:0] msg_type);
    //     case (msg_type)
    //         "A": return 36;
    //         "X": return 23;
    //         "U": return 27;
    //         "D": return 9;
    //         "E": return 30;
    //         "P": return 40;
    //         default: return 2;
    //     endcase
    // endfunction

    // logic [5:0] suppress_count;
    logic [5:0] byte_index;
    logic       is_trade;

    // wire decoder_enabled = (suppress_count == 0);

    // Suppression logic
    // always_ff @(posedge clk) begin
    //     if (rst) begin
    //         suppress_count <= 0;
    //     end else if (suppress_count != 0) begin
    //         suppress_count <= suppress_count - 1;
    //     end
    // end

    // Main decode logic
    always_ff @(posedge clk) begin
        if (rst) begin
            byte_index            <= 0;
            is_trade              <= 0;
            trade_internal_valid  <= 0;
            trade_packet_invalid  <= 0;
            trade_timestamp       <= 0;
            trade_order_ref       <= 0;
            trade_side            <= 0;
            trade_shares          <= 0;
            trade_stock_symbol    <= 0;
            trade_price           <= 0;
            trade_match_id        <= 0;
        end else if (valid_in && decoder_enabled) begin
            trade_internal_valid <= 0;
            trade_packet_invalid <= 0;

            if (byte_index == 0) begin
                is_trade <= (byte_in == MSG_TYPE);
                if (byte_in == MSG_TYPE)
                    byte_index <= 1;
                else begin
                    suppress_count <= itch_length(byte_in) - 2;
                    is_trade       <= 0;
                    byte_index     <= 0;
                end
            end else begin
                byte_index <= byte_index + 1;
            end

            if (is_trade) begin
                case (byte_index)
                    1:  trade_timestamp[47:40] <= byte_in;
                    2:  trade_timestamp[39:32] <= byte_in;
                    3:  trade_timestamp[31:24] <= byte_in;
                    4:  trade_timestamp[23:16] <= byte_in;
                    5:  trade_timestamp[15:8]  <= byte_in;
                    6:  trade_timestamp[7:0]   <= byte_in;

                    7:  trade_order_ref[63:56] <= byte_in;
                    8:  trade_order_ref[55:48] <= byte_in;
                    9:  trade_order_ref[47:40] <= byte_in;
                    10: trade_order_ref[39:32] <= byte_in;
                    11: trade_order_ref[31:24] <= byte_in;
                    12: trade_order_ref[23:16] <= byte_in;
                    13: trade_order_ref[15:8]  <= byte_in;
                    14: trade_order_ref[7:0]   <= byte_in;

                    15: trade_side <= (byte_in == "S");


                    16: trade_shares[31:24] <= byte_in;
                    17: trade_shares[23:16] <= byte_in;
                    18: trade_shares[15:8]  <= byte_in;
                    19: trade_shares[7:0]   <= byte_in;

                    20: trade_stock_symbol[63:56] <= byte_in;
                    21: trade_stock_symbol[55:48] <= byte_in;
                    22: trade_stock_symbol[47:40] <= byte_in;
                    23: trade_stock_symbol[39:32] <= byte_in;
                    24: trade_stock_symbol[31:24] <= byte_in;
                    25: trade_stock_symbol[23:16] <= byte_in;
                    26: trade_stock_symbol[15:8]  <= byte_in;
                    27: trade_stock_symbol[7:0]   <= byte_in;

                    28: trade_price[31:24] <= byte_in;
                    29: trade_price[23:16] <= byte_in;
                    30: trade_price[15:8]  <= byte_in;
                    31: trade_price[7:0]   <= byte_in;

                    32: trade_match_id[63:56] <= byte_in;
                    33: trade_match_id[55:48] <= byte_in;
                    34: trade_match_id[47:40] <= byte_in;
                    35: trade_match_id[39:32] <= byte_in;
                    36: trade_match_id[31:24] <= byte_in;
                    37: trade_match_id[23:16] <= byte_in;
                    38: trade_match_id[15:8]  <= byte_in;
                    39: trade_match_id[7:0]   <= byte_in;
                endcase

                if (byte_index == MSG_LENGTH - 1)
                    trade_internal_valid <= 1;
            end

            if (byte_index >= MSG_LENGTH && is_trade)
                trade_packet_invalid <= 1;
        end

        if (is_trade && (
            (valid_in == 0 && byte_index > 0 && byte_index < MSG_LENGTH) ||
            (byte_index >= MSG_LENGTH)
        ))
            trade_packet_invalid <= 1;

        if (byte_index == MSG_LENGTH) begin
            trade_internal_valid <= 0;
            trade_packet_invalid <= 0;
            trade_timestamp      <= 0;
            trade_order_ref      <= 0;
            trade_side           <= 0;
            trade_shares         <= 0;
            trade_stock_symbol   <= 0;
            trade_price          <= 0;
            trade_match_id       <= 0;

            if (valid_in && byte_in == MSG_TYPE) begin
                is_trade   <= 1;
                byte_index <= 1;
            end else if (valid_in) begin
                is_trade       <= 0;
                byte_index     <= 0;
                suppress_count <= itch_length(byte_in) - 2;
            end else begin
                is_trade   <= 0;
                byte_index <= 0;
            end
        end
    end

endmodule

