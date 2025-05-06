// =============================================
// add_order_decoder.v
// =============================================
//
// Description: Zero-wait speculative Add Order decoder for ITCH feed.
//              Begins decoding at byte 0 and maps order_ref from byte 1.
// Author: RZ
// Start Date: 20250430
// Version: 0.6
//
// Changelog
// =============================================
// [20250430-1] RZ: Initial speculative streaming implementation.
// [20250501-1] RZ: Renamed misc_data to stock_symbol.
// [20250501-2] RZ: Fixed byte index off-by-one.
// [20250501-3] RZ: Fully speculative decode without waiting for type match.
// [20250501-4] RZ: Rebased order_ref to start at byte 1 (byte 0 is msg_type).
// [20250502-1] RZ: Added self disable and zeroing of signals after message parsing completion.
// =============================================

// ------------------------------------------------------------------------------------------------
// Architecture Notes:
// ------------------------------------------------------------------------------------------------
// The ITCH "Add Order" ('A') message has a fixed length of 36 bytes and is structured as:
//   [0]     = Message Type (ASCII 'A')
//   [1:8]   = Order Reference Number (64-bit)
//   [9]     = Buy/Sell Indicator ('B' or 'S')
//   [10:13] = Number of Shares (32-bit)
//   [14:21] = Stock Symbol (8 ASCII characters, space-padded)
//   [22:25] = Price (32-bit, fixed-point with 4 implied decimal places)
//
// This decoder consumes a byte-alWigned, per-cycle stream of ITCH bytes and speculatively 
// begins parsing at cycle 0. On cycle 0, it captures the message type and immediately decodes
// byte 1 as `order_ref[63:56]`. Parallel validation confirms whether the message is of type 'A'.
// The decoder asserts `internal_valid` after 36 valid cycles only if the type matches.
//
// Inputs:
//   - clk           : system clock
//   - rst           : synchronous reset
//   - byte_in[7:0]  : ITCH byte stream (1 byte per cycle)
//   - valid_in      : asserted high when byte_in is valid
//
// Outputs:
//   - internal_valid: one-cycle pulse when a valid Add Order message is fully parsed
//   - packet_invalid: asserted if message length overruns unexpectedly (optional use)
//   - order_ref     : 64-bit parsed order reference number
//   - side          : 1-bit flag, 1 = sell ('S'), 0 = buy ('B')
//   - shares        : 32-bit parsed number of shares
//   - price         : 32-bit fixed-point price
//   - stock_symbol  : 64-bit ASCII stock symbol (left-justified, space-padded)
// ------------------------------------------------------------------------------------------------
module add_order_decoder (
    input  logic        clk,
    input  logic        rst,
    input  logic [7:0]  byte_in,
    input  logic        valid_in,

    output logic        add_internal_valid,
    output logic        add_packet_invalid,

    output logic [63:0] add_order_ref,
    output logic        add_side,
    output logic [31:0] add_shares,
    output logic [31:0] add_price,
    output logic [63:0] add_stock_symbol
);

    parameter MSG_TYPE   = 8'h41;   // ASCII 'A'
    parameter MSG_LENGTH = 36;

    `include "macros/itch_len.vh"


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

    logic [5:0] suppress_count;
    logic [5:0] byte_index;
    logic       is_add_order;

    wire decoder_enabled = (suppress_count == 0);

    // Suppression logic
    always_ff @(posedge clk) begin
        if (rst) begin
            suppress_count <= 0;
        end else if (suppress_count != 0) begin
            suppress_count <= suppress_count - 1;
        end
    end

    // Main decode logic
    always_ff @(posedge clk) begin
        if (rst) begin
            byte_index         <= 0;
            is_add_order       <= 0;
            add_internal_valid <= 0;
            add_packet_invalid <= 0;
            add_order_ref      <= 0;
            add_side           <= 0;
            add_shares         <= 0;
            add_price          <= 0;
            add_stock_symbol   <= 0;
        end else if (valid_in && decoder_enabled) begin
            add_internal_valid <= 0;
            add_packet_invalid <= 0;

            if (byte_index == 0) begin
                is_add_order <= (byte_in == MSG_TYPE);
                if (byte_in == MSG_TYPE)
                    byte_index <= 1;
                else begin
                    suppress_count <= itch_length(byte_in) - 2;
                    is_add_order   <= 0;
                    byte_index     <= 0;
                end
            end else begin
                byte_index <= byte_index + 1;
            end

            if (is_add_order) begin
                case (byte_index)
                    1:  add_order_ref[63:56]     <= byte_in;
                    2:  add_order_ref[55:48]     <= byte_in;
                    3:  add_order_ref[47:40]     <= byte_in;
                    4:  add_order_ref[39:32]     <= byte_in;
                    5:  add_order_ref[31:24]     <= byte_in;
                    6:  add_order_ref[23:16]     <= byte_in;
                    7:  add_order_ref[15:8]      <= byte_in;
                    8:  add_order_ref[7:0]       <= byte_in;
                    9:  add_side                 <= (byte_in == "S");
                    10: add_shares[31:24]        <= byte_in;
                    11: add_shares[23:16]        <= byte_in;
                    12: add_shares[15:8]         <= byte_in;
                    13: add_shares[7:0]          <= byte_in;
                    14: add_stock_symbol[63:56]  <= byte_in;
                    15: add_stock_symbol[55:48]  <= byte_in;
                    16: add_stock_symbol[47:40]  <= byte_in;
                    17: add_stock_symbol[39:32]  <= byte_in;
                    18: add_stock_symbol[31:24]  <= byte_in;
                    19: add_stock_symbol[23:16]  <= byte_in;
                    20: add_stock_symbol[15:8]   <= byte_in;
                    21: add_stock_symbol[7:0]    <= byte_in;
                    22: add_price[31:24]         <= byte_in;
                    23: add_price[23:16]         <= byte_in;
                    24: add_price[15:8]          <= byte_in;
                    25: add_price[7:0]           <= byte_in;
                endcase

                if (byte_index == MSG_LENGTH - 1)
                    add_internal_valid <= 1;
            end

            if (byte_index >= MSG_LENGTH && is_add_order)
                add_packet_invalid <= 1;
        end

        if (is_add_order && (
            (valid_in == 0 && byte_index > 0 && byte_index < MSG_LENGTH) ||
            (byte_index >= MSG_LENGTH)
        ))
            add_packet_invalid <= 1;

        // --- Reset or prepare next ---
        if (byte_index == MSG_LENGTH) begin
            add_internal_valid <= 0;
            add_packet_invalid <= 0;
            add_order_ref      <= 0;
            add_side           <= 0;
            add_shares         <= 0;
            add_price          <= 0;
            add_stock_symbol   <= 0;

            if (valid_in && byte_in == MSG_TYPE) begin
                is_add_order <= 1;
                byte_index   <= 1;
            end else if (valid_in) begin
                is_add_order   <= 0;
                byte_index     <= 0;
                suppress_count <= itch_length(byte_in) - 2;
            end else begin
                is_add_order <= 0;
                byte_index   <= 0;
            end
        end
    end

endmodule
