// =============================================
// top_test.v
// =============================================
//
// Description: Reusable top-level test wrapper for module-level Cocotb simulation.
//              Uses `ifdef` blocks to selectively instantiate a single DUT (e.g. header_parser).
// Author: RZ
// Start Date: 04292025
// Version: 0.1
//
// Changelog
// =============================================
// [20250429-1] RZ: Initial version created for testing header_parser in isolation.
// [20250429-2] RZ: Designed for general reuse by other modules via `ifdef` blocks.
// =============================================
`timescale 1ns/1ps
module top_test (
    input wire clk,
    input wire rst_n,

    // Shared I/O for all test targets
    input wire [7:0] tcp_payload_in,
    input wire       tcp_byte_valid_in,

    output wire       start_flag,
    output wire [7:0] payload_out,
    output wire       payload_valid_out
 
);

`ifdef TEST_HEADER_PARSER
    header_parser u_header_parser (
        .clk(clk),
        .rst_n(rst_n),
        .tcp_payload_in(tcp_payload_in),
        .tcp_byte_valid_in(tcp_byte_valid_in),
        .start_flag(start_flag),
        .payload_out(payload_out),
        .payload_valid_out(payload_valid_out)
    );
`endif

`ifdef COCOTB_SIM
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, top_test);
end
`endif

endmodule
