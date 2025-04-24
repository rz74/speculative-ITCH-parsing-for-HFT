module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/itch_parser.fst");
    $dumpvars(0, itch_parser);
end
endmodule
