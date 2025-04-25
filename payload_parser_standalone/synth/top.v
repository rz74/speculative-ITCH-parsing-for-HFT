module top (
    input  wire        clk,
    input  wire        rst_n,

    input  wire        in_valid,
    input  wire [7:0]  msg_type,
    input  wire [511:0] payload,

    output wire        add_order_decoded,
    output wire [63:0] order_ref,
    output wire        buy_sell,
    output wire [31:0] shares,
    output wire [31:0] price,
    output wire [63:0] stock_symbol
);

    wire        add_order_valid;
    wire [511:0] add_order_payload;

    payload_dispatcher dispatcher_inst (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(in_valid),
        .msg_type(msg_type),
        .payload(payload),
        .add_order_valid(add_order_valid),
        .add_order_payload(add_order_payload)
    );

    add_order_decoder add_order_decoder_inst (
        .clk(clk),
        .rst_n(rst_n),
        .valid(add_order_valid),
        .payload(add_order_payload),
        .order_ref(order_ref),
        .buy_sell(buy_sell),
        .shares(shares),
        .price(price),
        .stock_symbol(stock_symbol),
        .decoded(add_order_decoded)
    );

`ifdef COCOTB_SIM
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, top);
    end
`endif

endmodule