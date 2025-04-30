// =============================================
// add_order_decoder.v
// =============================================
//
// Description: Module to decode Add Order ('A') messages from ITCH payloads.
// Author: RZ
// Start Date: 04172025
// Version: 0.1
//
// Changelog
// =============================================
// [20250427-1] RZ: Initial version created for Add Order payload decoding.
// [20250428-1] RZ: Updated ports and internal signals for dispatcher integration.
// [20250428-2] RZ: Added valid_flag signal
// [20250429-1] RZ: wired to length_validator module
// =============================================

`timescale 1ns/1ps

module add_order_decoder (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        valid,
    input  wire [511:0] payload,

    output reg         add_order_decoded,
    output reg [63:0]  order_ref,
    output reg         buy_sell,
    output reg [31:0]  shares,
    output reg [31:0]  price,
    output reg [63:0]  stock_symbol,
    output wire        valid_flag
);

// Internal parsing
wire [7:0] msg_type;
assign msg_type = payload[511:504];
//assign valid_flag = 1'b1;  // placeholder for testing                    


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        add_order_decoded <= 1'b0;
        order_ref <= 64'd0;
        buy_sell <= 1'b0;
        shares <= 32'd0;
        price <= 32'd0;
        stock_symbol <= 64'd0;
    end else if (valid) begin
        if (msg_type == "A") begin
            add_order_decoded <= 1'b1;
            order_ref <= payload[503:440];
            buy_sell <= (payload[439:432] == "B") ? 1'b1 : 1'b0; // 1=Buy, 0=Sell
            shares <= payload[431:400];
            stock_symbol <= payload[399:336];
            price <= payload[335:304];

            
            
        end else begin
            add_order_decoded <= 1'b0;
        end
    end else begin
        add_order_decoded <= 1'b0;
        
    end
end

length_validator validator_inst (
    .clk(clk),
    .rst_n(rst_n),
    .start(valid),
    .expected_len(16'd36),
    .byte_valid(valid),
    .valid_flag(valid_flag),
    .length_error() // unused for now
);

endmodule
