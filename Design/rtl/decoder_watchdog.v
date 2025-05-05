// =============================================
// decoder_watchdog.v
// =============================================
// Description:
//   Generic watchdog module for ITCH decoders.
//   Detects stalled or truncated packets based on
//   non-incrementing byte_index while valid_in is high.
//
// Author: RZ
// Version: 0.1 (05012025)
// Changelog:
// [20250501-1] RZ: Initial implementation based on decoder patterns.
// [20250501-2] RZ: Added parameterization for stall cycles and index width.
// =============================================

`timescale 1ns/1ps

module decoder_watchdog #(
    parameter STALL_CYCLES = 1,
    parameter INDEX_WIDTH = 6
) (
    input  logic             clk,
    input  logic             rst,
    input  logic             valid_in,
    input  logic             is_active,
    input  logic [INDEX_WIDTH-1:0] byte_index,
    output logic             stuck_flag
);

    logic [INDEX_WIDTH-1:0] last_index;
    logic [$clog2(STALL_CYCLES+1)-1:0] stall_counter;

    always_ff @(posedge clk) 
    begin
        if (rst || !is_active) 
        begin
            last_index   <= 0;
            stall_counter <= 0;
            stuck_flag   <= 0;
        end 
        else if (valid_in && is_active) 
        begin
            if (byte_index == last_index && byte_index != 0) 
            begin
                if (stall_counter == STALL_CYCLES - 1)
                    stuck_flag <= 1;
                else
                    stall_counter <= stall_counter + 1;
            end 
            else 
            begin
                stall_counter <= 0;
                stuck_flag <= 0;
            end
            last_index <= byte_index;
        end
    end

        `ifdef COCOTB_SIM
            initial 
            begin
                $dumpfile("dump.vcd");
                $dumpvars(0, decoder_watchdog);
            end
        `endif

endmodule
