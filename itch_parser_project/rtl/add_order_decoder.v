// ============================================================================
// Module: add_order_decoder
// Purpose: Decode fields from ITCH 'A' (Add Order) message
// Industry Reference: Nasdaq TotalView-ITCH 5.0 Spec
// Architecture Choice: Standalone decoder, latency-optimized, simple unpacking.
// Pros: Clear field separation, clean input interface
// Cons: Assumes valid input is properly routed from dispatcher
// ============================================================================

module add_order_decoder (
    input  wire        clk,
    input  wire        rst_n,

    input  wire        valid,
    input  wire [511:0] payload,  // Assumes max 64B message width

    output reg  [64-1:0] order_ref,
    output reg           buy_sell,   // 0 = Buy, 1 = Sell
    output reg  [32-1:0] shares,
    output reg  [32-1:0] price,
    output reg           decoded
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            order_ref <= 0;
            buy_sell  <= 0;
            shares    <= 0;
            price     <= 0;
            decoded   <= 0;
        end else begin
            decoded <= 0;
            if (valid) begin
                // ITCH 'A' format:
                // 0  = 'A' (1 byte)
                // 1–8  = Order Ref Number (8 bytes)
                // 9    = Buy/Sell ('B' or 'S')
                // 10–13 = Shares (4 bytes)
                // 14–17 = Stock Symbol (not decoded here)
                // 18–21 = Price (4 bytes)
                order_ref <= payload[511-8*1 -: 64]; // bytes 1–8
                buy_sell  <= (payload[511-8*9 -: 8] == "S") ? 1'b1 : 1'b0;
                shares    <= payload[511-8*10 -: 32];
                price     <= payload[511-8*18 -: 32];
                decoded   <= 1'b1;
            end
        end
    end

endmodule
