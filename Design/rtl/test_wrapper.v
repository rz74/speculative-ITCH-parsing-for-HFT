// =============================================
// test_wrapper.v
// =============================================
//
// Description: Top-level test wrapper for ITCH parser system.
//              Instantiates all decoders and connects to parser.v.
// Author: RZ
// Start Date: 20250505
// Version: 0.2
// =============================================

module test_wrapper (
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
    output logic [63:0] new_order_ref,
    output logic [47:0] timestamp,
    output logic [63:0] misc_data
);

    // Add Order Decoder
    logic add_internal_valid;
    logic [3:0]  add_parsed_type;
    logic [63:0] add_order_ref;
    logic        add_side;
    logic [31:0] add_shares;
    logic [31:0] add_price;
    logic [63:0] add_stock_symbol;

    // Cancel Order Decoder
    logic cancel_internal_valid;
    logic [3:0]  cancel_parsed_type;
    logic [63:0] cancel_order_ref;
    logic [31:0] cancel_canceled_shares;

    // Delete Order Decoder
    logic delete_internal_valid;
    logic [3:0]  delete_parsed_type;
    logic [63:0] delete_order_ref;

    // Replace Order Decoder
    logic replace_internal_valid;
    logic [3:0]  replace_parsed_type;
    logic [63:0] replace_old_order_ref;
    logic [63:0] replace_new_order_ref;
    logic [31:0] replace_shares;
    logic [31:0] replace_price;

    // Executed Order Decoder
    logic exec_internal_valid;
    logic [3:0]  exec_parsed_type;
    logic [63:0] exec_order_ref;
    logic [31:0] exec_shares;
    logic [47:0] exec_timestamp;
    logic [63:0] exec_match_id;

    // Trade Decoder
    logic trade_internal_valid;
    logic [3:0]  trade_parsed_type;
    logic [63:0] trade_order_ref;
    logic        trade_side;
    logic [31:0] trade_shares;
    logic [31:0] trade_price;
    logic [47:0] trade_timestamp;
    logic [63:0] trade_stock_symbol;
    logic [63:0] trade_match_id;

    // Instantiate decoders
    add_order_decoder u_add (
        .clk(clk), .rst(rst), .byte_in(byte_in), .valid_in(valid_in),
        .add_internal_valid(add_internal_valid),
        .add_parsed_type(add_parsed_type),
        .add_order_ref(add_order_ref),
        .add_side(add_side),
        .add_shares(add_shares),
        .add_price(add_price),
        .add_stock_symbol(add_stock_symbol)
    );

    cancel_order_decoder u_cancel (
        .clk(clk), .rst(rst), .byte_in(byte_in), .valid_in(valid_in),
        .cancel_internal_valid(cancel_internal_valid),
        .cancel_parsed_type(cancel_parsed_type),
        .cancel_order_ref(cancel_order_ref),
        .cancel_canceled_shares(cancel_canceled_shares)
    );

    delete_order_decoder u_delete (
        .clk(clk), .rst(rst), .byte_in(byte_in), .valid_in(valid_in),
        .delete_internal_valid(delete_internal_valid),
        .delete_parsed_type(delete_parsed_type),
        .delete_order_ref(delete_order_ref)
    );

    replace_order_decoder u_replace (
        .clk(clk), .rst(rst), .byte_in(byte_in), .valid_in(valid_in),
        .replace_internal_valid(replace_internal_valid),
        .replace_parsed_type(replace_parsed_type),
        .replace_old_order_ref(replace_old_order_ref),
        .replace_new_order_ref(replace_new_order_ref),
        .replace_shares(replace_shares),
        .replace_price(replace_price)
    );

    executed_order_decoder u_exec (
        .clk(clk), .rst(rst), .byte_in(byte_in), .valid_in(valid_in),
        .exec_internal_valid(exec_internal_valid),
        .exec_parsed_type(exec_parsed_type),
        .exec_order_ref(exec_order_ref),
        .exec_shares(exec_shares),
        .exec_timestamp(exec_timestamp),
        .exec_match_id(exec_match_id)
    );

    trade_decoder u_trade (
        .clk(clk), .rst(rst), .byte_in(byte_in), .valid_in(valid_in),
        .trade_internal_valid(trade_internal_valid),
        .trade_parsed_type(trade_parsed_type),
        .trade_order_ref(trade_order_ref),
        .trade_side(trade_side),
        .trade_shares(trade_shares),
        .trade_price(trade_price),
        .trade_timestamp(trade_timestamp),
        .trade_stock_symbol(trade_stock_symbol),
        .trade_match_id(trade_match_id)
    );

    // Instantiate parser
    parser u_parser (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),

        .add_internal_valid(add_internal_valid),
        .cancel_internal_valid(cancel_internal_valid),
        .delete_internal_valid(delete_internal_valid),
        .replace_internal_valid(replace_internal_valid),
        .exec_internal_valid(exec_internal_valid),
        .trade_internal_valid(trade_internal_valid),

        .add_parsed_type(add_parsed_type),
        .cancel_parsed_type(cancel_parsed_type),
        .delete_parsed_type(delete_parsed_type),
        .replace_parsed_type(replace_parsed_type),
        .exec_parsed_type(exec_parsed_type),
        .trade_parsed_type(trade_parsed_type),

        .add_order_ref(add_order_ref),
        .cancel_order_ref(cancel_order_ref),
        .delete_order_ref(delete_order_ref),
        .replace_old_order_ref(replace_old_order_ref),
        .replace_new_order_ref(replace_new_order_ref),
        .exec_order_ref(exec_order_ref),
        .trade_order_ref(trade_order_ref),

        .add_side(add_side),
        .trade_side(trade_side),

        .add_shares(add_shares),
        .cancel_canceled_shares(cancel_canceled_shares),
        .replace_shares(replace_shares),
        .exec_shares(exec_shares),
        .trade_shares(trade_shares),

        .add_price(add_price),
        .replace_price(replace_price),
        .trade_price(trade_price),

        .exec_timestamp(exec_timestamp),
        .trade_timestamp(trade_timestamp),

        .add_stock_symbol(add_stock_symbol),
        .exec_match_id(exec_match_id),
        .trade_match_id(trade_match_id),

        .parsed_valid(parsed_valid),
        .parsed_type(parsed_type),
        .order_ref(order_ref),
        .side(side),
        .shares(shares),
        .price(price),
        .new_order_ref(new_order_ref),
        .timestamp(timestamp),
        .misc_data(misc_data)
    );

        // ======================= Waveform Dump =======================
    `ifdef COCOTB_SIM
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, test_wrapper);
    end
    `endif
    
endmodule
