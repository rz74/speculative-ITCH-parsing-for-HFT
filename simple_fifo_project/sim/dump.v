module dump_waveform;
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, fifo);
    end
endmodule
