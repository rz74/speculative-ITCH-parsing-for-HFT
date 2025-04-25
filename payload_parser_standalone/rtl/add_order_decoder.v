module add_order_decoder (
    input  wire        clk,
    input  wire        rst_n,

    input  wire        valid,
    input  wire [511:0] payload,

    output reg  [63:0] order_ref,
    output reg         buy_sell,
    output reg  [31:0] shares,
    output reg  [31:0] price,
    output reg  [63:0] stock_symbol,
    output reg         decoded
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            order_ref     <= 0;
            buy_sell      <= 0;
            shares        <= 0;
            price         <= 0;
            stock_symbol  <= 0;
            decoded       <= 0;
        end else begin
            decoded <= 0;
            if (valid) begin
                order_ref     <= payload[511-8*1  -: 64];   // 1–8
                buy_sell      <= (payload[511-8*9  -: 8] == "S") ? 1'b1 : 1'b0; // 9
                shares        <= payload[511-8*10 -: 32];   // 10–13
                stock_symbol  <= payload[511-8*14 -: 64];   // 14–21
                price         <= payload[511-8*22 -: 32];   // 22–25
                decoded       <= 1'b1;
            end
        end
    end

endmodule