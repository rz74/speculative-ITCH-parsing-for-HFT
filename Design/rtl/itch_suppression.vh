`ifndef ITCH_SUPPRESSION_VH
`define ITCH_SUPPRESSION_VH

`define ITCH_SUPPRESSION_LOGIC(clk, rst, suppress_count) \
    always_ff @(posedge clk) begin \
        if (rst) begin \
            suppress_count <= 0; \
        end else if (suppress_count != 0) begin \
            suppress_count <= suppress_count - 1; \
        end \
    end

`define ITCH_DECODER_ENABLED(suppress_count) \
    wire decoder_enabled = (suppress_count == 0);

`endif
