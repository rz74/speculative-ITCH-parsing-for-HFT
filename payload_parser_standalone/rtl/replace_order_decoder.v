// =============================================
// replace_order_decoder.v
// =============================================
//
// Description: Decode Replace Order ('U') ITCH messages.
// Author: RZ
// Start Date: 20250428
//
// Changelog
// =============================================
// [20250428-1] RZ: Initial Replace Order decoder implementation.
// =============================================

`timescale 1ns/1ps

module replace_order_decoder (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        valid,
    input  wire [511:0] payload,

    output reg         replace_order_decoded,
    output reg [63:0]  original_ref,
    output reg [63:0]  new_ref,
    output reg [31:0]  shares
);

wire [7:0] msg_type = payload[511:504];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        replace_order_decoded <= 1'b0;
        original_ref <= 64'd0;
        new_ref <= 64'd0;
        shares <= 32'd0;
    end else if (valid && msg_type == "U") begin
        replace_order_decoded <= 1'b1;
        original_ref <= payload[503:440];
        new_ref <= payload[439:376];
        shares <= payload[375:344];
    end else begin
        replace_order_decoded <= 1'b0;
    end
end

endmodule
