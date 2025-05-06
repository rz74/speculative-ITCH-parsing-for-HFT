// ============================================================
// itch_fields_executed.vh
// Signal mapping and field reset for Executed Order decoder
// ============================================================

`define internal_valid   exec_internal_valid
`define packet_invalid   exec_packet_invalid
`define order_ref        exec_order_ref
`define shares           exec_shares
`define match_id         exec_match_id
`define timestamp        exec_timestamp
`define is_order         is_exec_order   // used by ITCH_CORE_DECODE

`define ITCH_RESET_FIELDS        \
    `internal_valid <= 0;        \
    `packet_invalid <= 0;        \
    `order_ref      <= 0;        \
    `shares         <= 0;        \
    `match_id       <= 0;        \
    `timestamp      <= 0;
