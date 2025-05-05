`ifndef ITCH_UTILS_VH
`define ITCH_UTILS_VH

`include "itch_suppression.vh"
`include "itch_core_decode.vh"
`include "itch_reset.vh"

function automatic logic [5:0] itch_length(input logic [7:0] msg_type);
    case (msg_type)
        "A": return 36;
        "X": return 23;
        "U": return 27;
        "D": return 9;
        "E": return 30;
        "P": return 40;
        default: return 2;
    endcase
endfunction

`define ITCH_DECODER_MODULE(MODULE_NAME, MSG_TYPE, MSG_LENGTH, internal_valid, packet_invalid, order_flag, byte_index, suppress_count, order_ref, FIELD_ASSIGN_BLOCK) \
module MODULE_NAME ( \
    input  logic        clk, \
    input  logic        rst, \
    input  logic [7:0]  byte_in, \
    input  logic        valid_in, \
    output logic        internal_valid, \
    output logic        packet_invalid, \
    output logic [63:0] order_ref \
); \
    logic [5:0] suppress_count; \
    logic [5:0] byte_index; \
    logic       order_flag; \
    `ITCH_SUPPRESSION_LOGIC(clk, rst, suppress_count) \
    always_ff @(posedge clk) begin \
        if (rst) begin \
            byte_index       <= 0; \
            internal_valid   <= 0; \
            packet_invalid   <= 0; \
            order_ref        <= 0; \
            order_flag       <= 0; \
        end else begin \
            internal_valid   <= 0; \
            packet_invalid   <= 0; \
            if (valid_in && suppress_count == 0) begin \
                if (byte_index == 0) begin \
                    order_flag <= (byte_in == MSG_TYPE); \
                    if (byte_in == MSG_TYPE) \
                        byte_index <= 1; \
                    else begin \
                        suppress_count <= itch_length(byte_in) - 2; \
                        order_flag <= 0; \
                        byte_index <= 0; \
                    end \
                end else begin \
                    byte_index <= byte_index + 1; \
                    case (byte_index) \
                        FIELD_ASSIGN_BLOCK \
                    endcase \
                    if (byte_index == (MSG_LENGTH - 1)) \
                        internal_valid <= 1; \
                    if (order_flag && (byte_index >= MSG_LENGTH || (valid_in == 0 && byte_index < MSG_LENGTH))) \
                        packet_invalid <= 1; \
                end \
            end \
            `ITCH_FINAL_BYTE_RESET(MSG_LENGTH, MSG_TYPE, internal_valid, packet_invalid, order_ref, order_flag, byte_index, suppress_count) \
        end \
    end \
endmodule

`endif
