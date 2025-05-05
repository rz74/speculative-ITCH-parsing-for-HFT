`ifndef ITCH_RESET_VH
`define ITCH_RESET_VH

`define ITCH_FINAL_BYTE_RESET(MSG_LENGTH, MSG_TYPE, internal_valid, packet_invalid, order_ref1, order_flag, byte_index, suppress_count) \
    if (byte_index == MSG_LENGTH) begin \
        internal_valid   <= 0; \
        packet_invalid   <= 0; \
        order_ref1       <= 0; \
        `ifdef ITCH_HAS_ORDER_REF2 \
            order_ref2 <= 0; \
        `endif \
        `ifdef ITCH_HAS_SHARES \
            shares <= 0; \
        `endif \
        `ifdef ITCH_HAS_PRICE \
            price <= 0; \
        `endif \
        if (valid_in && byte_in == MSG_TYPE) begin \
            order_flag <= 1; \
            byte_index <= 1; \
        end else if (valid_in) begin \
            order_flag <= 0; \
            byte_index <= 0; \
            suppress_count <= itch_length(byte_in) - 2; \
        end else begin \
            order_flag <= 0; \
            byte_index <= 0; \
        end \
    end

`endif
