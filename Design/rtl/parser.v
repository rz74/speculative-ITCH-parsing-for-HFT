// =============================================
// parser.v
// =============================================
//
// Description: Canonical output wrapper that muxes all decoder outputs
//              from speculative ITCH message parsing. Assumes only one
//              decoder asserts *_internal_valid per cycle.
// Author: RZ
// Start Date: 20250505
// Version: 0.2
//
// =============================================

module parser (
    input  logic clk,
    input  logic rst,
    input  logic valid_in, 

    // Decoder outputs
    input  logic        add_internal_valid,
    input  logic        cancel_internal_valid,
    input  logic        delete_internal_valid,
    input  logic        replace_internal_valid,
    input  logic        exec_internal_valid,
    input  logic        trade_internal_valid,

    input  logic [3:0]  add_parsed_type,
    input  logic [3:0]  cancel_parsed_type,
    input  logic [3:0]  delete_parsed_type,
    input  logic [3:0]  replace_parsed_type,
    input  logic [3:0]  exec_parsed_type,
    input  logic [3:0]  trade_parsed_type,

    input  logic [63:0] add_order_ref,
    input  logic [63:0] cancel_order_ref,
    input  logic [63:0] delete_order_ref,
    input  logic [63:0] replace_old_order_ref,
    input  logic [63:0] replace_new_order_ref,
    input  logic [63:0] exec_order_ref,
    input  logic [63:0] trade_order_ref,

    input  logic        add_side,
    input  logic        trade_side,

    input  logic [31:0] add_shares,
    input  logic [31:0] cancel_canceled_shares,
    input  logic [31:0] replace_shares,
    input  logic [31:0] exec_shares,
    input  logic [31:0] trade_shares,

    input  logic [31:0] replace_price,
    input  logic [31:0] add_price,
    input  logic [31:0] trade_price,

    input  logic [47:0] exec_timestamp,
    input  logic [47:0] trade_timestamp,

    input  logic [63:0] add_stock_symbol,
    input  logic [63:0] trade_match_id,
    input  logic [63:0] exec_match_id,

    // Canonical output interface
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

    // XOR-valid only if one-hot, and valid_in is high
    assign parsed_valid = valid_in & (
        add_internal_valid    ^ cancel_internal_valid ^
        delete_internal_valid ^ replace_internal_valid ^
        exec_internal_valid   ^ trade_internal_valid);

    assign parsed_type =
        add_internal_valid     ? add_parsed_type    :
        cancel_internal_valid  ? cancel_parsed_type :
        delete_internal_valid  ? delete_parsed_type :
        replace_internal_valid ? replace_parsed_type :
        exec_internal_valid    ? exec_parsed_type   :
        trade_internal_valid   ? trade_parsed_type  : 4'd0;

    assign order_ref =
        add_internal_valid     ? add_order_ref    :
        cancel_internal_valid  ? cancel_order_ref :
        delete_internal_valid  ? delete_order_ref :
        exec_internal_valid    ? exec_order_ref   :
        trade_internal_valid   ? trade_order_ref  : 64'd0;

    assign side =
        add_internal_valid     ? add_side         :
        trade_internal_valid   ? trade_side       : 1'b0;

    assign shares =
        add_internal_valid     ? add_shares             :
        cancel_internal_valid  ? cancel_canceled_shares :
        replace_internal_valid ? replace_shares         :
        exec_internal_valid    ? exec_shares            :
        trade_internal_valid   ? trade_shares           : 32'd0;

    assign price =
        add_internal_valid     ? add_price         :
        replace_internal_valid ? replace_price     :
        trade_internal_valid   ? trade_price       : 64'd0;

    assign new_order_ref =
        replace_internal_valid ? replace_new_order_ref : 64'd0;

    assign timestamp =
        exec_internal_valid    ? exec_timestamp    :
        trade_internal_valid   ? trade_timestamp   : 32'd0;

    assign misc_data =
        add_internal_valid     ? add_stock_symbol      :
        trade_internal_valid   ? trade_match_id        :
        exec_internal_valid    ? exec_match_id         :
        replace_internal_valid ? replace_old_order_ref : 64'd0;

    // ======================= Waveform Dump =======================
    `ifdef COCOTB_SIM
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, parser);
    end
    `endif

endmodule
