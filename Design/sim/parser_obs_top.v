// =============================================
// parser_obs_top.v
// =============================================
// Description: Top-level wrapper for parser observation test
// Taps into internal decoder outputs within itch_parser without modifying itch_parser.v
// =============================================

`timescale 1ns/1ps

module parser_obs_top (
    input  logic        clk,
    input  logic        rst,
    input  logic [7:0]  byte_in,
    input  logic        valid_in,

    output logic        parsed_valid,
    output logic [3:0]  parsed_type,
    output logic [63:0] order_ref,

    output logic        add_internal_valid,
    output logic [63:0] add_order_ref,
    output logic [31:0] add_shares,
    output logic [31:0] add_price,

    output logic        cancel_internal_valid,
    output logic [63:0] cancel_order_ref,
    output logic [31:0] cancel_canceled_shares,

    output logic        delete_internal_valid,
    output logic [63:0] delete_order_ref,

    output logic        replace_internal_valid,
    output logic [63:0] replace_old_order_ref,

    output logic        executed_internal_valid,
    output logic [63:0] executed_order_ref,

    output logic        trade_internal_valid,
    output logic [63:0] trade_order_ref
);

    // Instantiate the ITCH parser
    itch_parser dut (
        .clk(clk),
        .rst(rst),
        .byte_in(byte_in),
        .valid_in(valid_in),
        .parsed_valid(parsed_valid),
        .parsed_type(parsed_type),
        .order_ref(order_ref)
    );

    // Tap internal decoder outputs
    assign add_internal_valid     = dut.u_add_order_decoder.add_internal_valid;
    assign add_order_ref          = dut.u_add_order_decoder.add_order_ref;
    assign add_shares             = dut.u_add_order_decoder.add_shares;
    assign add_price              = dut.u_add_order_decoder.add_price;

    assign cancel_internal_valid  = dut.u_cancel_order_decoder.cancel_internal_valid;
    assign cancel_order_ref       = dut.u_cancel_order_decoder.cancel_order_ref;
    assign cancel_canceled_shares = dut.u_cancel_order_decoder.cancel_canceled_shares;

    assign delete_internal_valid  = dut.u_delete_order_decoder.delete_internal_valid;
    assign delete_order_ref       = dut.u_delete_order_decoder.delete_order_ref;

    assign replace_internal_valid = dut.u_replace_order_decoder.replace_internal_valid;
    assign replace_old_order_ref  = dut.u_replace_order_decoder.replace_old_order_ref;

    assign executed_internal_valid = dut.u_executed_order_decoder.exec_internal_valid;
    assign executed_order_ref      = dut.u_executed_order_decoder.exec_order_ref;

    assign trade_internal_valid   = dut.u_trade_decoder.trade_internal_valid;
    assign trade_order_ref        = dut.u_trade_decoder.trade_order_ref;

endmodule
