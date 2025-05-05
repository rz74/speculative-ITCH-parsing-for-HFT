`ifndef ITCH_CORE_DECODE_VH
`define ITCH_CORE_DECODE_VH

`define ITCH_CORE_DECODER_LOGIC(MSG_TYPE, MSG_LENGTH, internal_valid, packet_invalid, order_flag, byte_index, suppress_count) \
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
    end \
    if (byte_index == MSG_LENGTH - 1) \
        internal_valid <= 1; \
    if (byte_index >= MSG_LENGTH && order_flag) \
        packet_invalid <= 1; \
    if (order_flag && ((valid_in == 0 && byte_index > 0 && byte_index < MSG_LENGTH) || (byte_index >= MSG_LENGTH))) \
        packet_invalid <= 1;

`endif
