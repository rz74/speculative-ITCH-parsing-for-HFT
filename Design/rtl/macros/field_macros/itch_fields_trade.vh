// ============================================================
// itch_fields_trade.vh
// Signal mapping and field reset for Trade decoder
// ============================================================

`define internal_valid    trade_internal_valid
`define packet_invalid    trade_packet_invalid
`define timestamp         trade_timestamp
`define order_ref         trade_order_ref
`define side              trade_side
`define shares            trade_shares
`define stock_symbol      trade_stock_symbol
`define price             trade_price
`define match_id          trade_match_id

`define ITCH_RESET_FIELDS            \
    `internal_valid    <= 0;         \
    `packet_invalid    <= 0;         \
    `timestamp         <= 0;         \
    `order_ref         <= 0;         \
    `side              <= 0;         \
    `shares            <= 0;         \
    `stock_symbol      <= 0;         \
    `price             <= 0;         \
    `match_id          <= 0;
