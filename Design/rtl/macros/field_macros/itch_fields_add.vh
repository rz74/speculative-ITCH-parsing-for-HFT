// =============================================
// itch_fields_add.vh
// =============================================
//
// Description: Signal name indirection and reset assignment macro for Add Order decoder.
// Author: RZ
// Start Date: 20250505
// Version: 0.1
//
// Changelog
// =============================================
// [20250505-1] RZ: Initial field mapping for add_order_decoder.

`define internal_valid   add_internal_valid
`define packet_invalid   add_packet_invalid
`define order_ref        add_order_ref
`define side             add_side
`define shares           add_shares
`define price            add_price
`define stock_symbol     add_stock_symbol
`define is_order         is_add_order   //used by ITCH_CORE_DECODE

`define ITCH_RESET_FIELDS        \
    `internal_valid <= 0;        \
    `packet_invalid <= 0;        \
    `order_ref      <= 0;        \
    `side           <= 0;        \
    `shares         <= 0;        \
    `price          <= 0;        \
    `stock_symbol   <= 0;
