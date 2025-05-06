// ============================================================
// itch_fields_cancel.vh
// Signal mapping and field reset for Cancel Order decoder
// ============================================================

`define internal_valid    cancel_internal_valid
`define packet_invalid    cancel_packet_invalid
`define order_ref         cancel_order_ref
`define canceled_shares   cancel_canceled_shares

`define ITCH_RESET_FIELDS        \
    `internal_valid    <= 0;     \
    `packet_invalid    <= 0;     \
    `order_ref         <= 0;     \
    `canceled_shares   <= 0;
