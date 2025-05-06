// ============================================================
// itch_fields_delete.vh
// Signal mapping and field reset for Delete Order decoder
// ============================================================

`define internal_valid   delete_internal_valid
`define packet_invalid   delete_packet_invalid
`define order_ref        delete_order_ref
`define is_order         is_delete_order   // used by ITCH_CORE_DECODE

`define ITCH_RESET_FIELDS        \
    `internal_valid <= 0;        \
    `packet_invalid <= 0;        \
    `order_ref      <= 0;
