// =============================================
// top.v
// =============================================
//
// Description: Top-level wrapper for cocotb simulation, handles VCD dumping.
// Author: RZ
// Start Date: 04172025
// Version: 0.1
//
// Changelog
// =============================================
// [20250427-1] RZ: Updated VCD dumping to allow dynamic filename selection via DUMPFILE macro.
// [20250428-1] RZ: Standardized dumpfile to "dump.vcd" for all simulation targets.
// [20250428-2] RZ: Updated dispatcher instantiation to match new decoded signal structure.
// [20250428-3] RZ: Added Replace Order decoder instantiation and connections.
// [20250428-4] RZ: Fixed syntax errors in module instantiation and signal connections.
// =============================================

`timescale 1ns/1ps

module top (
    input  wire        clk,
    input  wire        rst_n,

    input  wire        in_valid,
    input  wire [7:0]  msg_type,
    input  wire [511:0] payload,

    output wire        add_order_decoded,
    output wire [63:0] order_ref,
    output wire        buy_sell,
    output wire [31:0] add_order_shares,
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
    output wire [31:0] replace_order_shares
);

payload_dispatcher dispatcher_inst (
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid),
    .msg_type(msg_type),
    .payload(payload),

    .add_order_decoded(add_order_decoded),
    .order_ref(order_ref),
    .buy_sell(buy_sell),
    .shares(add_order_shares),
    .price(price),
    .stock_symbol(stock_symbol),

    .cancel_order_decoded(cancel_order_decoded),
    .cancel_order_ref(cancel_order_ref),
    .cancel_shares(cancel_shares),

    .delete_order_decoded(delete_order_decoded),
    .delete_order_ref(delete_order_ref),

    .replace_order_decoded(replace_order_decoded),
    .original_ref(original_ref),
    .new_ref(new_ref),
    .shares_replace(replace_order_shares)
);

`ifdef COCOTB_SIM
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, top);
end
`endif

endmodule

