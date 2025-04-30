// =============================================
// delete_order_decoder.v
// =============================================
//
// Description: Module to decode Delete Order ('D') messages from ITCH payloads.
// Author: RZ
// Start Date: 04172025
// Version: 0.1
//
// Changelog
// =============================================
// [20250428-1] RZ: Initial scaffold of Delete Order payload decoder module.
// [20250428-2] RZ: Updated ports and internal signals for valid_flag
// =============================================

`timescale 1ns/1ps

module delete_order_decoder (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        valid,
    input  wire [511:0] payload,

    output reg         delete_order_decoded,
    output reg [63:0]  delete_order_ref,
    output wire        valid_flag
    

);

// Internal signals
wire [7:0] msg_type;
wire [63:0] order_ref;

assign msg_type = payload[511:504];     // Byte 0 (MSB side first) — Message Type
assign order_ref = payload[503:440];    // Bytes 1-8 — Order Reference Number

assign valid_flag = 1'b1;  // Always valid initially, later overwritten by length validator

// Decode logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        delete_order_decoded <= 1'b0;
        delete_order_ref <= 64'd0;
    end else if (valid) begin
        if (msg_type == "D") begin
            delete_order_decoded <= 1'b1;
            delete_order_ref <= order_ref;
        end else begin
            delete_order_decoded <= 1'b0;
            delete_order_ref <= 64'd0;
        end
    end else begin
        delete_order_decoded <= 1'b0;
    end
end

endmodule
