`timescale 1ns/1ps

module tb_wrapper;

    // Testbench signals
    reg clk = 0;
    reg rst = 1;
    reg [7:0] rx_data = 0;
    reg rx_valid = 0;
    wire [7:0] msg_type;
    wire [15:0] msg_len;
    wire new_msg;

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    // Instantiate the DUT
    itch_parser dut (
        .clk(clk),
        .rst(rst),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .msg_type(msg_type),
        .msg_len(msg_len),
        .new_msg(new_msg)
    );

    // Dump VCD waveform
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_wrapper);
    end

endmodule
