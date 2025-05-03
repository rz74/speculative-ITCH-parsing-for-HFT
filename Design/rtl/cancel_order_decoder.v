// =============================================
// cancel_order_decoder.v
// =============================================
//
// Description: Module to decode Cancel Order ('X') messages from ITCH payloads.
// Author: RZ
// Start Date: 04172025
// Version: 0.5
// Changelog
// =============================================
// [20250427-1] RZ: Initial version created for Cancel Order payload decoding.
// [20250428-1] RZ: Updated ports and internal signals for dispatcher integration.
// [20250428-2] RZ: Added valid_flag signal 
// [20250501-1] RZ: Initial implementation based on add_order_decoder structure with new arch.
// [20250502-1] RZ: Added self disable and zeroing of signals after message parsing completion.
// 
// =============================================
// ------------------------------------------------------------------------------------------------
// Architecture Notes:
// ------------------------------------------------------------------------------------------------
// The ITCH "Cancel Order" ('X') message has a fixed length of 23 bytes and is structured as:
//   [0]      = Message Type (ASCII 'X')
//   [1:8]    = Order Reference Number (64-bit)
//   [9:12]   = Canceled Shares (32-bit)
//   [13:22]  = Reserved bytes (ignored)
//
// This decoder consumes a byte-aligned, per-cycle stream of ITCH bytes and speculatively 
// begins parsing at cycle 0. On cycle 0, it captures the message type and immediately decodes
// byte 1 as `order_ref[63:56]`. Parallel validation confirms whether the message is of type 'X'.
// The decoder asserts `internal_valid` after 23 valid cycles only if the type matches.
//
// Inputs:
//   - clk            : system clock
//   - rst            : synchronous reset
//   - byte_in[7:0]   : ITCH byte stream (1 byte per cycle)
//   - valid_in       : asserted high when byte_in is valid
//
// Outputs:
//   - internal_valid : one-cycle pulse when a valid Cancel Order message is fully parsed
//   - packet_invalid : asserted if message length overruns unexpectedly (optional use)
//   - order_ref      : 64-bit parsed order reference number
//   - canceled_shares: 32-bit parsed canceled share quantity
// ------------------------------------------------------------------------------------------------
module cancel_order_decoder (
    input  logic        clk,
    input  logic        rst,
    input  logic [7:0]  byte_in,
    input  logic        valid_in,

    output logic        cancel_internal_valid,
    output logic        cancel_packet_invalid,

    output logic [63:0] cancel_order_ref,
    output logic [31:0] cancel_canceled_shares
);

    parameter MSG_TYPE   = 8'h58;   // ASCII 'X'
    parameter MSG_LENGTH = 23;

    // ITCH message length mapping
    function automatic logic [5:0] itch_length(input logic [7:0] msg_type);
        case (msg_type)
            "A": return 36;
            "X": return 23;
            "U": return 27;
            "D": return 9;
            "E": return 30;
            "P": return 44;
            default: return 2;
        endcase
    endfunction

    logic [5:0] suppress_count;
    logic [5:0] byte_index;
    logic       is_cancel_order;

    wire decoder_enabled = (suppress_count == 0);

    // Suppression counter
    always_ff @(posedge clk) begin
        if (rst) begin
            suppress_count <= 0;
        end else if (suppress_count != 0) begin
            suppress_count <= suppress_count - 1;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            byte_index              <= 0;
            is_cancel_order         <= 0;
            cancel_internal_valid   <= 0;
            cancel_packet_invalid   <= 0;
            cancel_order_ref        <= 0;
            cancel_canceled_shares  <= 0;
        end else if (valid_in && decoder_enabled) begin
            cancel_internal_valid <= 0;
            cancel_packet_invalid <= 0;

            if (byte_index == 0) begin
                is_cancel_order <= (byte_in == MSG_TYPE);
                if (byte_in == MSG_TYPE)
                    byte_index <= 1;
                else begin
                    suppress_count     <= itch_length(byte_in) - 2;
                    is_cancel_order    <= 0;
                    byte_index         <= 0;
                end
            end else begin
                byte_index <= byte_index + 1;
            end

            if (is_cancel_order) begin
                case (byte_index)
                    1:  cancel_order_ref[63:56]       <= byte_in;
                    2:  cancel_order_ref[55:48]       <= byte_in;
                    3:  cancel_order_ref[47:40]       <= byte_in;
                    4:  cancel_order_ref[39:32]       <= byte_in;
                    5:  cancel_order_ref[31:24]       <= byte_in;
                    6:  cancel_order_ref[23:16]       <= byte_in;
                    7:  cancel_order_ref[15:8]        <= byte_in;
                    8:  cancel_order_ref[7:0]         <= byte_in;
                    9:  cancel_canceled_shares[31:24] <= byte_in;
                    10: cancel_canceled_shares[23:16] <= byte_in;
                    11: cancel_canceled_shares[15:8]  <= byte_in;
                    12: cancel_canceled_shares[7:0]   <= byte_in;
                endcase

                if (byte_index == MSG_LENGTH - 1)
                    cancel_internal_valid <= 1;
            end

            if (byte_index >= MSG_LENGTH && is_cancel_order)
                cancel_packet_invalid <= 1;
        end

        // Defensive invalid packet catch
        if (is_cancel_order && (
            (valid_in == 0 && byte_index > 0 && byte_index < MSG_LENGTH) ||
            (byte_index >= MSG_LENGTH)
        ))
            cancel_packet_invalid <= 1;

        // --- Clear or prepare for next ---
        if (byte_index == MSG_LENGTH) begin
            cancel_internal_valid   <= 0;
            cancel_packet_invalid   <= 0;
            cancel_order_ref        <= 0;
            cancel_canceled_shares  <= 0;

            if (valid_in && byte_in == MSG_TYPE) begin
                is_cancel_order <= 1;
                byte_index      <= 1;
            end else if (valid_in) begin
                is_cancel_order <= 0;
                byte_index      <= 0;
                suppress_count  <= itch_length(byte_in) - 2;
            end else begin
                is_cancel_order <= 0;
                byte_index      <= 0;
            end
        end
    end

endmodule


