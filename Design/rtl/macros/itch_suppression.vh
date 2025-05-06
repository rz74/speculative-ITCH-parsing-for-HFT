// ============================================================
// itch_suppression.vh
// Handles suppression count and decoder enable logic
// ============================================================

logic [5:0] suppress_count;
wire decoder_enabled = (suppress_count == 0);

always_ff @(posedge clk) begin
    if (rst)
        suppress_count <= 0;
    else if (suppress_count != 0)
        suppress_count <= suppress_count - 1;
end
