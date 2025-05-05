`timescale 1ns/1ps
module top_test (
    input        clk,
    input        rst,
    input  [7:0] byte_in,
    input        valid_in,
    output       internal_valid,
    output       packet_invalid,
    output [63:0] order_ref,
    output        side,
    output [31:0] shares,
    output [63:0] price,
    output [31:0] timestamp,
    output [63:0] misc_data
);

`ifdef TEST_ADD_ORDER_DECODER
    add_order_decoder u_add_order_decoder (
        .clk(clk),
        .rst(rst),
        .byte_in(byte_in),
        .valid_in(valid_in),
        .internal_valid(internal_valid),
        .packet_invalid(packet_invalid),
        .order_ref(order_ref),
        .side(side),
        .shares(shares),
        .price(price),
        .timestamp(timestamp),
        .misc_data(misc_data)
    );
`endif

`ifdef COCOTB_SIM
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, top_test);
end
`endif

endmodule
