// ============================================================
// itch_parser.v
// ============================================================
// Description:
//   Unified ITCH parser module that integrates all supported decoders
//   and outputs a merged parsed result in a single cycle.
//
// Author: RZ
// Date: 05012025
// ============================================================

`timescale 1ns/1ps

module itch_parser (
    input  logic        clk,
    input  logic        rst,
    input  logic [7:0]  byte_in,
    input  logic        valid_in,

    output logic        parsed_valid,
    output logic [3:0]  parsed_type,

    output logic [63:0] order_ref,
    output logic        side,
    output logic [31:0] shares,
    output logic [31:0] price,
    output logic [63:0] stock_symbol,
    output logic [63:0] match_id,
    output logic [31:0] timestamp,
    output logic [63:0] new_order_ref
);

    // Internal signals
    logic add_internal_valid, cancel_internal_valid, delete_internal_valid;
    logic replace_internal_valid, exec_internal_valid, trade_internal_valid;

    // Decoder outputs
    logic [63:0] add_order_ref, cancel_order_ref, delete_order_ref;
    logic [63:0] replace_old_order_ref, replace_new_order_ref;
    logic [63:0] exec_order_ref, trade_order_ref;

    logic        add_side;
    logic [31:0] add_shares, cancel_canceled_shares, replace_shares, exec_shares, trade_shares;
    logic [31:0] add_price, replace_price, trade_price;
    logic [63:0] add_stock_symbol, trade_stock_symbol;
    logic [63:0] exec_match_id, trade_match_id;
    logic [31:0] exec_timestamp, trade_timestamp;

    // Instantiate all decoders
    add_order_decoder u_add_order_decoder (
        .clk               (clk),
        .rst               (rst),
        .byte_in           (byte_in),
        .valid_in          (valid_in),
        .add_internal_valid(add_internal_valid),
        .add_order_ref     (add_order_ref),
        .add_side          (add_side),
        .add_shares        (add_shares),
        .add_price         (add_price),
        .add_stock_symbol  (add_stock_symbol)
    );

    cancel_order_decoder u_cancel_order_decoder (
        .clk                   (clk),
        .rst                   (rst),
        .byte_in               (byte_in),
        .valid_in              (valid_in),
        .cancel_internal_valid(cancel_internal_valid),
        .cancel_order_ref      (cancel_order_ref),
        .cancel_canceled_shares(cancel_canceled_shares)
    );

    delete_order_decoder u_delete_order_decoder (
        .clk                   (clk),
        .rst                   (rst),
        .byte_in               (byte_in),
        .valid_in              (valid_in),
        .delete_internal_valid(delete_internal_valid),
        .delete_order_ref      (delete_order_ref)
    );

    replace_order_decoder u_replace_order_decoder (
        .clk                   (clk),
        .rst                   (rst),
        .byte_in               (byte_in),
        .valid_in              (valid_in),
        .replace_internal_valid(replace_internal_valid),
        .replace_old_order_ref (replace_old_order_ref),
        .replace_new_order_ref (replace_new_order_ref),
        .replace_shares        (replace_shares),
        .replace_price         (replace_price)
    );

    executed_order_decoder u_executed_order_decoder (
        .clk                 (clk),
        .rst                 (rst),
        .byte_in             (byte_in),
        .valid_in            (valid_in),
        .exec_internal_valid (exec_internal_valid),
        .exec_order_ref      (exec_order_ref),
        .exec_shares         (exec_shares),
        .exec_match_id       (exec_match_id),
        .exec_timestamp      (exec_timestamp)
    );

    trade_decoder u_trade_decoder (
        .clk                  (clk),
        .rst                  (rst),
        .byte_in              (byte_in),
        .valid_in             (valid_in),
        .trade_internal_valid (trade_internal_valid),
        .trade_order_ref      (trade_order_ref),
        .trade_shares         (trade_shares),
        .trade_match_id       (trade_match_id),
        .trade_stock_symbol   (trade_stock_symbol),
        .trade_price          (trade_price),
        .trade_timestamp      (trade_timestamp)
    );

    // Arbitration logic
    always_comb begin
        parsed_valid      = 0;
        parsed_type       = 4'd15;
        order_ref         = 0;
        side              = 0;
        shares            = 0;
        price             = 0;
        stock_symbol      = 0;
        match_id          = 0;
        timestamp         = 0;
        new_order_ref     = 0;

        if (add_internal_valid) begin
            parsed_valid  = 1;
            parsed_type   = 4'd1;
            order_ref     = add_order_ref;
            side          = add_side;
            shares        = add_shares;
            price         = add_price;
            stock_symbol  = add_stock_symbol;
        end else if (cancel_internal_valid) begin
            parsed_valid  = 1;
            parsed_type   = 4'd2;
            order_ref     = cancel_order_ref;
            shares        = cancel_canceled_shares;
        end else if (delete_internal_valid) begin
            parsed_valid  = 1;
            parsed_type   = 4'd3;
            order_ref     = delete_order_ref;
        end else if (replace_internal_valid) begin
            parsed_valid  = 1;
            parsed_type   = 4'd4;
            order_ref     = replace_old_order_ref;
            new_order_ref = replace_new_order_ref;
            shares        = replace_shares;
            price         = replace_price;
        end else if (exec_internal_valid) begin
            parsed_valid  = 1;
            parsed_type   = 4'd5;
            order_ref     = exec_order_ref;
            shares        = exec_shares;
            match_id      = exec_match_id;
            timestamp     = exec_timestamp;
        end else if (trade_internal_valid) begin
            parsed_valid  = 1;
            parsed_type   = 4'd6;
            order_ref     = trade_order_ref;
            shares        = trade_shares;
            match_id      = trade_match_id;
            stock_symbol  = trade_stock_symbol;
            price         = trade_price;
            timestamp     = trade_timestamp;
        end
    end


    // ======================= Waveform Dump =======================
    `ifdef COCOTB_SIM
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, itch_parser);
    end
    `endif

endmodule
