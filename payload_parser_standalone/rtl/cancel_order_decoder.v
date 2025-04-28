module cancel_order_decoder (
    input  wire        clk,
    input  wire        rst_n,

    input  wire        valid,
    input  wire [511:0] payload,

    output reg  [63:0] order_ref,
    output reg  [31:0] cancel_shares,
    output reg         decoded
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            order_ref     <= 64'd0;
            cancel_shares <= 32'd0;
            decoded       <= 1'b0;
        end else begin
            decoded <= 1'b0;
            if (valid) begin
                order_ref     <= payload[511-8*1  -: 64]; // bytes 1-8: order reference
                cancel_shares <= payload[511-8*9  -: 32]; // bytes 9-12: cancel shares
                decoded       <= 1'b1;
            end
        end
    end

endmodule
