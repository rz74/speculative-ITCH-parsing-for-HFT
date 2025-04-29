// =============================================
// length_validator.v
// =============================================
//
// Description:
// Parallel module to validate incoming ITCH payload length.
// Latches expected length from header at `start` pulse.
// Counts incoming bytes via `byte_valid` signal.
// When byte count == expected length → asserts `valid_flag`.
// Raises `length_error` if byte count exceeds expected length.
// Intended to run alongside speculative parser without blocking.
//
// Author: RZ
// Start Date: 20250429
// Version: 0.1
//
// Changelog
// =============================================
// [20250428-1] RZ: Initial implementation of speculative parallel length checker.
// =============================================

`timescale 1ns/1ps

module length_validator (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,          // latch new expected_len
    input  wire [15:0] expected_len,   // expected message length in bytes
    input  wire        byte_valid,     // each clock: one valid byte received

    output wire        valid_flag,     // high when byte_count == expected_len
    output wire        length_error    // high if byte_count > expected_len
);

    reg [15:0] length_latched;
    reg [15:0] byte_count;
    reg        flag_done;
    reg        error_flag;

    // Latch expected length on 'start'
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            length_latched <= 16'd0;
        end else if (start) begin
            length_latched <= expected_len;
        end
    end

    // Count incoming bytes
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            byte_count <= 16'd0;
            flag_done <= 1'b0;
            error_flag <= 1'b0;
        end else if (start) begin
            byte_count <= 16'd0;
            flag_done <= 1'b0;
            error_flag <= 1'b0;
        end else if (byte_valid && !flag_done) begin
            byte_count <= byte_count + 1;
            if (byte_count + 1 == length_latched)
                flag_done <= 1'b1;
            else if (byte_count + 1 > length_latched)
                error_flag <= 1'b1;
        end
    end

    assign valid_flag = flag_done && !error_flag;
    assign length_error = error_flag;

endmodule
