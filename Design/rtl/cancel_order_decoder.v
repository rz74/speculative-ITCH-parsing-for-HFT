// =============================================
// cancel_order_decoder.v
// =============================================
//
// Description: Module to decode Cancel Order ('X') messages from ITCH payloads.
// Author: RZ
// Start Date: 04172025
// Version: 0.1
//
// Changelog
// =============================================
// [20250427-1] RZ: Initial version created for Cancel Order payload decoding.
// [20250428-1] RZ: Updated ports and internal signals for dispatcher integration.
// [20250428-2] RZ: Added valid_flag signal 
// =============================================

`timescale 1ns/1ps

module cancel_order_decoder (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        valid,
    input  wire [511:0] payload,

    output reg         cancel_order_decoded,
    output reg [63:0]  cancel_order_ref,
    output reg [31:0]  cancel_shares,
    output wire        valid_flag
    

);

// Internal parsing
wire [7:0] msg_type;
assign msg_type = payload[511:504];
assign valid_flag = 1'b1;  // Always valid initially, later overwritten by length validator

always @(posedge clk or negedge rst_n) begin
    
    if (!rst_n) begin
        cancel_order_decoded <= 1'b0;
        cancel_order_ref <= 64'd0;
        cancel_shares <= 32'd0;
    end else if (valid) begin
        if (msg_type == "X") begin
            cancel_order_decoded <= 1'b1;
            cancel_order_ref <= payload[503:440];
            cancel_shares <= payload[439:408];
        end else begin
            cancel_order_decoded <= 1'b0;
        end
    end else begin
        cancel_order_decoded <= 1'b0;
        
    end
end

endmodule
