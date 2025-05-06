// =============================================
// executed_order_decoder.v
// =============================================
//
// Description: Speculative streaming Executed Order decoder.
//              Parses 30-byte ITCH 'E' messages from a raw byte stream.
//
// Author: RZ
// Start Date: 20250501
// Version: 0.2
//
// Changelog
// =============================================
// [20250501-1] RZ: Initial implementation based on cancel and replace decoder patterns.
// [20250502-1] RZ: Added self disable and zeroing of signals after message parsing completion.
// [20250504-1] RZ: Fixed timestamp width to 48-bit and corrected field byte ranges.
// =============================================

// ------------------------------------------------------------------------------------------------
// Protocol Version Note:
// ------------------------------------------------------------------------------------------------
// The ITCH "Executed Order" ('E') message has a fixed length of 30 bytes and is structured as:
//   [0]      = Message Type (ASCII 'E')
//   [1:6]    = Timestamp (48-bit, nanoseconds since midnight)
//   [7:14]   = Order Reference Number (64-bit)
//   [15:18]  = Executed Shares (32-bit)
//   [19:26]  = Match ID (64-bit)
//   [27:29]  = Reserved bytes (ignored)
//
// This decoder consumes a byte-aligned, per-cycle ITCH stream, beginning speculative parsing
// at byte 0. Internal signals are zeroed after parsing. Validation logic ensures length compliance.
// ------------------------------------------------------------------------------------------------

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
    output logic [47:0] exec_timestamp
);

    parameter MSG_TYPE   = 8'h45;  // ASCII 'E'
    parameter MSG_LENGTH = 30;

    `include "macros/itch_len.vh"
    `include "macros/itch_suppression.vh"
    `include "macros/field_macros/itch_fields_executed.vh"
    `include "macros/itch_reset.vh"


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
    logic       is_exec_order;

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
            byte_index          <= 0;
            is_exec_order       <= 0;
            `ITCH_RESET_LOGIC
            // exec_internal_valid <= 0;
            // exec_packet_invalid <= 0;
            // exec_order_ref      <= 0;
            // exec_shares         <= 0;
            // exec_match_id       <= 0;
            // exec_timestamp      <= 0;
        end else if (valid_in && decoder_enabled) begin
            exec_internal_valid <= 0;
            exec_packet_invalid <= 0;

            if (byte_index == 0) begin
                is_exec_order <= (byte_in == MSG_TYPE);
                if (byte_in == MSG_TYPE)
                    byte_index <= 1;
                else begin
                    suppress_count <= itch_length(byte_in) - 2;
                    is_exec_order  <= 0;
                    byte_index     <= 0;
                end
            end else begin
                byte_index <= byte_index + 1;
            end

            if (is_exec_order) begin
                case (byte_index)
                    1:  exec_timestamp[47:40] <= byte_in;
                    2:  exec_timestamp[39:32] <= byte_in;
                    3:  exec_timestamp[31:24] <= byte_in;
                    4:  exec_timestamp[23:16] <= byte_in;
                    5:  exec_timestamp[15:8]  <= byte_in;
                    6:  exec_timestamp[7:0]   <= byte_in;

                    7:  exec_order_ref[63:56] <= byte_in;
                    8:  exec_order_ref[55:48] <= byte_in;
                    9:  exec_order_ref[47:40] <= byte_in;
                    10: exec_order_ref[39:32] <= byte_in;
                    11: exec_order_ref[31:24] <= byte_in;
                    12: exec_order_ref[23:16] <= byte_in;
                    13: exec_order_ref[15:8]  <= byte_in;
                    14: exec_order_ref[7:0]   <= byte_in;

                    15: exec_shares[31:24]    <= byte_in;
                    16: exec_shares[23:16]    <= byte_in;
                    17: exec_shares[15:8]     <= byte_in;
                    18: exec_shares[7:0]      <= byte_in;

                    19: exec_match_id[63:56]  <= byte_in;
                    20: exec_match_id[55:48]  <= byte_in;
                    21: exec_match_id[47:40]  <= byte_in;
                    22: exec_match_id[39:32]  <= byte_in;
                    23: exec_match_id[31:24]  <= byte_in;
                    24: exec_match_id[23:16]  <= byte_in;
                    25: exec_match_id[15:8]   <= byte_in;
                    26: exec_match_id[7:0]    <= byte_in;
                endcase

                if (byte_index == MSG_LENGTH - 1)
                    exec_internal_valid <= 1;
            end

            if (byte_index >= MSG_LENGTH && is_exec_order)
                exec_packet_invalid <= 1;
        end

        if (is_exec_order && (
            (valid_in == 0 && byte_index > 0 && byte_index < MSG_LENGTH) ||
            (byte_index >= MSG_LENGTH)
        ))
            exec_packet_invalid <= 1;

        if (byte_index == MSG_LENGTH) begin
            exec_internal_valid <= 0;
            exec_packet_invalid <= 0;
            exec_order_ref      <= 0;
            exec_shares         <= 0;
            exec_match_id       <= 0;
            exec_timestamp      <= 0;

            if (valid_in && byte_in == MSG_TYPE) begin
                is_exec_order <= 1;
                byte_index    <= 1;
            end else if (valid_in) begin
                is_exec_order   <= 0;
                byte_index      <= 0;
                suppress_count  <= itch_length(byte_in) - 2;
            end else begin
                is_exec_order <= 0;
                byte_index    <= 0;
            end
        end
    end

endmodule
