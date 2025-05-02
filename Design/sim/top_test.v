// =============================================
// top_test.v
// =============================================
//
// Description: Reusable top-level test wrapper for module-level Cocotb simulation.
//              Uses `ifdef` blocks to selectively instantiate a single DUT (e.g. header_parser).
// Author: RZ
// Start Date: 04292025
// Version: 0.10
//
// Changelog
// =============================================
// [20250429-1] RZ: Initial version created for testing header_parser in isolation.
// [20250429-2] RZ: Designed for general reuse by other modules via `ifdef` blocks.
// [20250429-3] RZ: Added testbench for add_order_decoder module.
// [20250429-4] RZ: Added testbench for top-level module to drive start_flag as output from header_parser.
// [20250430-1] RZ: Updated add_order_decoder module with new arch.
// [20250501-1] RZ: Added stock_symbol output to add_order_decoder module.
// [20250501-2] RZ: Fixed byte index off-by-one in add_order_decoder module.
// [20250501-3] RZ: Fully speculative decode without waiting for type match in add_order_decoder module.
// [20250501-4] RZ: Added cancel_order_decoder module for cancel order messages.
// [20250501-5] RZ: Gated dump under ifdef to avoid unnecessary waveform generation.
// [20250501-6] RZ: Added delete_order_decoder module for delete order messages.
// =============================================
`timescale 1ns/1ps

module top_test (

    // System Signals
    input  logic        clk,
    input  logic        rst,
    input  logic [7:0]  byte_in,
    input  logic        valid_in,

    // Add Order Decoder Outputs
    output logic        add_internal_valid,
    output logic        add_packet_invalid,
    output logic [63:0] add_order_ref,
    output logic        add_side,
    output logic [31:0] add_shares,
    output logic [31:0] add_price,
    output logic [63:0] add_stock_symbol,

    // Cancel Order Decoder Outputs
    output logic        cancel_internal_valid,
    output logic        cancel_packet_invalid,
    output logic [63:0] cancel_order_ref,
    output logic [31:0] cancel_canceled_shares,

    // Delete Order Decoder Outputs
    output logic        delete_internal_valid,
    output logic        delete_packet_invalid,
    output logic [63:0] delete_order_ref,

    // Replace Order Decoder Outputs
    output logic        replace_internal_valid,
    output logic        replace_packet_invalid,
    output logic [63:0] replace_old_order_ref,
    output logic [63:0] replace_new_order_ref,
    output logic [31:0] replace_shares,
    output logic [31:0] replace_price


);
// =============================================
// Module Instantiation
// =============================================

    `ifdef TEST_ADD_ORDER_DECODER
        add_order_decoder u_add_order_decoder (
            .clk               (clk),
            .rst               (rst),
            .byte_in           (byte_in),
            .valid_in          (valid_in),
            .add_internal_valid(add_internal_valid),
            .add_packet_invalid(add_packet_invalid),
            .add_order_ref     (add_order_ref),
            .add_side          (add_side),
            .add_shares        (add_shares),
            .add_price         (add_price),
            .add_stock_symbol  (add_stock_symbol)
        );
            // ======================= Waveform Dump =======================
        `ifdef COCOTB_SIM
        initial begin
            $dumpfile("dump.vcd");
            $dumpvars(0, u_add_order_decoder);
        end
        `endif
    `endif

    `ifdef TEST_CANCEL_ORDER_DECODER
        cancel_order_decoder u_cancel_order_decoder (
            .clk                   (clk),
            .rst                   (rst),
            .byte_in               (byte_in),
            .valid_in              (valid_in),
            .cancel_internal_valid(cancel_internal_valid),
            .cancel_packet_invalid(cancel_packet_invalid),
            .cancel_order_ref      (cancel_order_ref),
            .cancel_canceled_shares(cancel_canceled_shares)
        );
            // ======================= Waveform Dump =======================
        `ifdef COCOTB_SIM
        initial begin
            $dumpfile("dump.vcd");
            $dumpvars(0, u_cancel_order_decoder);
        end
        `endif
    `endif

    `ifdef TEST_DELETE_ORDER_DECODER
        delete_order_decoder u_delete_order_decoder (
            .clk                  (clk),
            .rst                  (rst),
            .byte_in              (byte_in),
            .valid_in             (valid_in),
            .delete_internal_valid(delete_internal_valid),
            .delete_packet_invalid(delete_packet_invalid),
            .delete_order_ref     (delete_order_ref)
        );
            // ======================= Waveform Dump =======================
            `ifdef COCOTB_SIM
            initial begin
                $dumpfile("dump.vcd");
                $dumpvars(0, u_delete_order_decoder);
            end
            `endif
    `endif

    `ifdef TEST_REPLACE_ORDER_DECODER
    replace_order_decoder u_replace_order_decoder (
        .clk                   (clk),
        .rst                   (rst),
        .byte_in               (byte_in),
        .valid_in              (valid_in),
        .replace_internal_valid(replace_internal_valid),
        .replace_packet_invalid(replace_packet_invalid),
        .replace_old_order_ref (replace_old_order_ref),
        .replace_new_order_ref (replace_new_order_ref),
        .replace_shares        (replace_shares),
        .replace_price         (replace_price)
    );
    `ifdef COCOTB_SIM
        initial begin
            $dumpfile("dump.vcd");
            $dumpvars(0, u_replace_order_decoder);
        end
        `endif
    `endif



    // // ======================= Waveform Dump =======================
    // `ifdef COCOTB_SIM
    // initial begin
    //     $dumpfile("dump.vcd");
    //     $dumpvars(0, top_test);
    // end
    // `endif

endmodule

