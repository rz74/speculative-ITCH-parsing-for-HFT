// ============================================================
// itch_fields_replace.vh
// Signal mapping and field reset for Replace Order decoder
// ============================================================

`define internal_valid    replace_internal_valid
`define packet_invalid    replace_packet_invalid
`define old_order_ref     replace_old_order_ref
`define new_order_ref     replace_new_order_ref
`define shares            replace_shares
`define price             replace_price

`define ITCH_RESET_FIELDS          \
    `internal_valid    <= 0;       \
    `packet_invalid    <= 0;       \
    `old_order_ref     <= 0;       \
    `new_order_ref     <= 0;       \
    `shares            <= 0;       \
    `price             <= 0;
