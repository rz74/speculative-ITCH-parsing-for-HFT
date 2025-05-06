// ============================================================
// itch_core_decode.vh
// Core decoding logic for message type match and byte tracking
// ============================================================

`define ITCH_CORE_DECODE(MSG_TYPE, MSG_LENGTH)              \
    if (byte_index == 0) begin                              \
        `is_order <= (byte_in == MSG_TYPE);                 \
        if (byte_in == MSG_TYPE) begin                      \
            byte_index <= 1;                                \
        end else begin                                      \
            suppress_count <= itch_length(byte_in) - 2;     \
            `is_order     <= 0;                             \
            byte_index    <= 0;                             \
        end                                                 \
    end else begin                                          \
        byte_index <= byte_index + 1;                       \
    end

`define ITCH_RECHECK_OR_SUPPRESS(MSG_TYPE, MSG_LENGTH)       \
    if (byte_index == MSG_LENGTH) begin                      \
        `ITCH_RESET_FIELDS                                   \
        if (valid_in && byte_in == MSG_TYPE) begin           \
            `is_order <= 1;                                  \
            byte_index <= 1;                                 \
        end else if (valid_in) begin                         \
            `is_order <= 0;                                  \
            byte_index <= 0;                                 \
            suppress_count <= itch_length(byte_in) - 2;      \
        end else begin                                       \
            `is_order <= 0;                                  \
            byte_index <= 0;                                 \
        end                                                  \
    end

