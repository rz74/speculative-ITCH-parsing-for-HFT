
// Changelog
// =============================================

// [04272025] RZ: Updated VCD dumping to allow dynamic filename selection via DUMPFILE macro.
//              Made this change to make debugging different modules easier
//==============================================

// ===============================
// top.v
// ===============================
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
    output wire [31:0] shares,
    output wire [31:0] price,
    output wire [63:0] stock_symbol,

    output wire        cancel_order_decoded,
    output wire [63:0] cancel_order_ref,
    output wire [31:0] cancel_shares
);

    wire        add_order_valid;
    wire [511:0] add_order_payload;

    wire        cancel_order_valid;
    wire [511:0] cancel_order_payload;

    payload_dispatcher dispatcher_inst (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(in_valid),
        .msg_type(msg_type),
        .payload(payload),
        .add_order_valid(add_order_valid),
        .add_order_payload(add_order_payload),
        .cancel_order_valid(cancel_order_valid),
        .cancel_order_payload(cancel_order_payload)
    );

    add_order_decoder add_order_decoder_inst (
        .clk(clk),
        .rst_n(rst_n),
        .valid(add_order_valid),
        .payload(add_order_payload),
        .order_ref(order_ref),
        .buy_sell(buy_sell),
        .shares(shares),
        .price(price),
        .stock_symbol(stock_symbol),
        .decoded(add_order_decoded)
    );

    cancel_order_decoder cancel_order_decoder_inst (
        .clk(clk),
        .rst_n(rst_n),
        .valid(cancel_order_valid),
        .payload(cancel_order_payload),
        .order_ref(cancel_order_ref),
        .cancel_shares(cancel_shares),
        .decoded(cancel_order_decoded)
    );

`ifdef COCOTB_SIM
    `ifdef DUMPFILE
        `define DUMPFILE_STRING `DUMPFILE
    `else
        `define DUMPFILE_STRING "default_dump.vcd"
    `endif

    initial begin
        $dumpfile(`DUMPFILE_STRING);
        $dumpvars(0, top);
    end
`endif




endmodule
