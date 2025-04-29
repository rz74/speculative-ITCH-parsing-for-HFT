// =============================================
// payload_dispatcher.v
// =============================================
//
// Description: Dispatcher module to route ITCH payloads based on message type.
// Author: RZ
// Start Date: 04172025
// Version: 0.1
//
// Changelog
// =============================================
// [20250427-1] RZ: Initial version supporting Add Order ('A') and Cancel Order ('X') dispatching.
// [20250428-1] RZ: Added Delete Order ('D') message dispatching.
// [20250428-2] RZ: wired valid flags from modules
// =============================================

`timescale 1ns/1ps

module payload_dispatcher (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        in_valid,
    input  wire [7:0]  msg_type,
    input  wire [511:0] payload,

    output wire        add_order_decoded,
    output wire [63:0] order_ref,
    output wire        buy_sell,
    output wire [31:0] shares,
    output wire [31:0] price,
    output wire [63:0] stock_symbol,

    output wire        cancel_order_decoded,
    output wire [63:0] cancel_order_ref,
    output wire [31:0] cancel_shares,

    output wire        delete_order_decoded,
    output wire [63:0] delete_order_ref,

    output wire        replace_order_decoded,
    output wire [63:0] original_ref,
    output wire [63:0] new_ref,
    output wire [31:0] shares_replace,

    output wire add_order_valid_flag,
    output wire cancel_order_valid_flag,
    output wire delete_order_valid_flag,
    output wire replace_order_valid_flag


);

// Submodule instances
add_order_decoder u_add_order_decoder (
    .clk(clk),
    .rst_n(rst_n),
    .valid(in_valid && (msg_type == "A")),
    .payload(payload),
    .add_order_decoded(add_order_decoded),
    .order_ref(order_ref),
    .buy_sell(buy_sell),
    .shares(shares),
    .price(price),
    .stock_symbol(stock_symbol),

    .valid_flag(add_order_valid_flag)
);

cancel_order_decoder u_cancel_order_decoder (
    .clk(clk),
    .rst_n(rst_n),
    .valid(in_valid && (msg_type == "X")),
    .payload(payload),
    .cancel_order_decoded(cancel_order_decoded),
    .cancel_order_ref(cancel_order_ref),
    .cancel_shares(cancel_shares),

    .valid_flag(cancel_order_valid_flag)
);

delete_order_decoder u_delete_order_decoder (
    .clk(clk),
    .rst_n(rst_n),
    .valid(in_valid && (msg_type == "D")),
    .payload(payload),
    .delete_order_decoded(delete_order_decoded),
    .delete_order_ref(delete_order_ref),

    .valid_flag(delete_order_valid_flag)
);

replace_order_decoder u_replace_order_decoder (
    .clk(clk),
    .rst_n(rst_n),
    .valid(in_valid && (msg_type == "U")),
    .payload(payload),
    .replace_order_decoded(replace_order_decoded),
    .original_ref(original_ref),
    .new_ref(new_ref),
    .shares(shares),

    .valid_flag(replace_order_valid_flag)
);


endmodule
