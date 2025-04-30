// =============================================
// top_test.v
// =============================================
//
// Description: Reusable top-level test wrapper for module-level Cocotb simulation.
//              Uses `ifdef` blocks to selectively instantiate a single DUT (e.g. header_parser).
// Author: RZ
// Start Date: 04292025
// Version: 0.3
//
// Changelog
// =============================================
// [20250429-1] RZ: Initial version created for testing header_parser in isolation.
// [20250429-2] RZ: Designed for general reuse by other modules via `ifdef` blocks.
// [20250429-3] RZ: Added testbench for add_order_decoder module.
// [20250429-4] RZ: Added testbench for top-level module to drive start_flag as output from header_parser.
// =============================================
`timescale 1ns/1ps
module top_test (
    input wire clk,
    input wire rst_n,

    input wire [7:0] tcp_payload_in,
    input wire       tcp_byte_valid_in,

    inout wire        start_flag,                
    output wire [7:0] payload_out,
    output wire       payload_valid_out,

    // Add Order Decoder Outputs
    output wire        add_order_decoded,
    output wire [63:0] order_ref,
    output wire        buy_sell,
    output wire [31:0] shares,
    output wire [63:0] stock_symbol,
    output wire [31:0] price
);

// ======================= DUT Selection Blocks =======================

`ifdef TEST_HEADER_PARSER
    // Drive start_flag as output from header_parser
    wire internal_start_flag;

    header_parser u_header_parser (
        .clk(clk),
        .rst_n(rst_n),
        .tcp_payload_in(tcp_payload_in),
        .tcp_byte_valid_in(tcp_byte_valid_in),
        .start_flag(internal_start_flag),
        .payload_out(payload_out),
        .payload_valid_out(payload_valid_out)
    );

    assign start_flag = internal_start_flag;  // drive toplevel
`endif

`ifdef TEST_ADD_ORDER_DECODER
    // Treat start_flag as input from testbench
    wire [7:0]  payload_in        = tcp_payload_in;
    wire        payload_valid_in  = tcp_byte_valid_in;
    wire        decoder_start_flag = start_flag;  // alias for clarity

    add_order_decoder u_add_order_decoder (
        .clk(clk),
        .rst_n(rst_n),
        .payload_in(payload_in),
        .payload_valid_in(payload_valid_in),
        .start_flag(decoder_start_flag),
        .add_order_decoded(add_order_decoded),
        .order_ref(order_ref),
        .buy_sell(buy_sell),
        .shares(shares),
        .stock_symbol(stock_symbol),
        .price(price)
    );
`endif

// ======================= Waveform Dump =======================
`ifdef COCOTB_SIM
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, top_test);
end
`endif

endmodule


