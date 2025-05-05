// =============================================
// delete_order_decoder.v
// =============================================
//
// Description: Speculative streaming Delete Order decoder.
//              Parses 9-byte ITCH 'D' messages from a raw byte stream.
// Author: RZ
// Start Date: 04172025
// Version: 0.4
//
// Changelog
// =============================================
// [20250428-1] RZ: Initial scaffold of Delete Order payload decoder module.
// [20250428-2] RZ: Updated ports and internal signals for valid_flag
// [20250501-1] RZ: Initial implementation based on new arch.
// [20250502-1] RZ: Added self disable and zeroing of signals after message parsing completion.
// =============================================
// ------------------------------------------------------------------------------------------------
// Protocol Version Note:
// ------------------------------------------------------------------------------------------------
// While older ITCH variants (e.g., ITCH 4.1 or proprietary BATS feeds) may define a Delete Order 
// message with 19 bytes including symbol information, the Nasdaq ITCH 5.0 specification defines 
// the 'D' message as exactly 9 bytes: a 1-byte message type and 8-byte order reference.
// This module implements the 9-byte ITCH 5.0 format.
// ------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------
// Architecture Notes:
// ------------------------------------------------------------------------------------------------
// The ITCH "Delete Order" ('D') message (Nasdaq ITCH 5.0) has a fixed length of 9 bytes and is structured as:
//   [0]      = Message Type (ASCII 'D')
//   [1:8]    = Order Reference Number (64-bit)
//
// This decoder consumes a byte-aligned, per-cycle stream of ITCH bytes and speculatively 
// begins parsing at cycle 0. On cycle 0, it captures the message type and immediately decodes
// byte 1 as `order_ref[63:56]`. Parallel validation confirms whether the message is of type 'D'.
// The decoder asserts `internal_valid` after 9 valid cycles only if the type matches.
//
// Inputs:
//   - clk               : system clock
//   - rst               : synchronous reset
//   - byte_in[7:0]      : ITCH byte stream (1 byte per cycle)
//   - valid_in          : asserted high when byte_in is valid
//
// Outputs:
//   - internal_valid    : one-cycle pulse when a valid Delete Order message is fully parsed
//   - packet_invalid    : asserted if message length overruns unexpectedly (optional use)
//   - order_ref         : 64-bit parsed order reference number
// ------------------------------------------------------------------------------------------------

// module delete_order_decoder (
//     input  logic        clk,
//     input  logic        rst,
//     input  logic [7:0]  byte_in,
//     input  logic        valid_in,

//     output logic        delete_internal_valid,
//     output logic        delete_packet_invalid,

//     output logic [63:0] delete_order_ref
// );

//     parameter MSG_TYPE   = 8'h44;  // ASCII 'D'
//     parameter MSG_LENGTH = 9;

//     function automatic logic [5:0] itch_length(input logic [7:0] msg_type);
//         case (msg_type)
//             "A": return 36;
//             "X": return 23;
//             "U": return 27;
//             "D": return 9;
//             "E": return 30;
//             "P": return 40;
//             default: return 2;
//         endcase
//     endfunction

//     logic [5:0] suppress_count;
//     logic [5:0] byte_index;
//     logic       is_delete_order;

//     wire decoder_enabled = (suppress_count == 0);

//     // Suppression logic
//     always_ff @(posedge clk) begin
//         if (rst) begin
//             suppress_count <= 0;
//         end else if (suppress_count != 0) begin
//             suppress_count <= suppress_count - 1;
//         end
//     end

//     // Main decode logic
//     always_ff @(posedge clk) begin
//         if (rst) begin
//             byte_index            <= 0;
//             is_delete_order       <= 0;
//             delete_internal_valid <= 0;
//             delete_packet_invalid <= 0;
//             delete_order_ref      <= 0;
//         end else if (valid_in && decoder_enabled) begin
//             delete_internal_valid <= 0;
//             delete_packet_invalid <= 0;

//             if (byte_index == 0) begin
//                 is_delete_order <= (byte_in == MSG_TYPE);
//                 if (byte_in == MSG_TYPE)
//                     byte_index <= 1;
//                 else begin
//                     suppress_count <= itch_length(byte_in) - 2;
//                     is_delete_order <= 0;
//                     byte_index <= 0;
//                 end
//             end else begin
//                 byte_index <= byte_index + 1;
//             end

//             if (is_delete_order) begin
//                 case (byte_index)
//                     1: delete_order_ref[63:56] <= byte_in;
//                     2: delete_order_ref[55:48] <= byte_in;
//                     3: delete_order_ref[47:40] <= byte_in;
//                     4: delete_order_ref[39:32] <= byte_in;
//                     5: delete_order_ref[31:24] <= byte_in;
//                     6: delete_order_ref[23:16] <= byte_in;
//                     7: delete_order_ref[15:8]  <= byte_in;
//                     8: delete_order_ref[7:0]   <= byte_in;
//                 endcase

//                 if (byte_index == MSG_LENGTH - 1)
//                     delete_internal_valid <= 1;
//             end

//             if (byte_index >= MSG_LENGTH && is_delete_order)
//                 delete_packet_invalid <= 1;
//         end

//         if (is_delete_order && (
//             (valid_in == 0 && byte_index > 0 && byte_index < MSG_LENGTH) ||
//             (byte_index >= MSG_LENGTH)
//         ))
//             delete_packet_invalid <= 1;

//         if (byte_index == MSG_LENGTH) begin
//             delete_internal_valid <= 0;
//             delete_packet_invalid <= 0;
//             delete_order_ref      <= 0;

//             if (valid_in && byte_in == MSG_TYPE) begin
//                 is_delete_order <= 1;
//                 byte_index <= 1;
//             end else if (valid_in) begin
//                 is_delete_order <= 0;
//                 byte_index <= 0;
//                 suppress_count <= itch_length(byte_in) - 2;
//             end else begin
//                 is_delete_order <= 0;
//                 byte_index <= 0;
//             end
//         end
//     end

// endmodule


`include "itch_utils.vh"

`ITCH_DECODER_MODULE(
    delete_order_decoder, "D", 9,
    delete_internal_valid, delete_packet_invalid,
    is_delete_order, byte_index, suppress_count,
    delete_order_ref,
    1: delete_order_ref[63:56] <= byte_in;
    2: delete_order_ref[55:48] <= byte_in;
    3: delete_order_ref[47:40] <= byte_in;
    4: delete_order_ref[39:32] <= byte_in;
    5: delete_order_ref[31:24] <= byte_in;
    6: delete_order_ref[23:16] <= byte_in;
    7: delete_order_ref[15:8]  <= byte_in;
    8: delete_order_ref[7:0]   <= byte_in;
)


