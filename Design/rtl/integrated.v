
// =====================================================
// integrated.v
// =====================================================
// Description: Integrated ITCH parser with Add and Cancel decoders
// =====================================================

module integrated (
    input  logic        clk,
    input  logic        rst,
    input  logic [7:0]  byte_in,
    input  logic        valid_in,

    output logic        add_internal_valid,
    output logic        cancel_internal_valid
);

    // Ignoring unused outputs for now
    logic        add_packet_invalid;
    logic [63:0] add_order_ref;
    logic        add_side;
    logic [31:0] add_shares;
    logic [31:0] add_price;
    logic [63:0] add_stock_symbol;

    logic        cancel_packet_invalid;
    logic [63:0] cancel_order_ref;
    logic [31:0] cancel_canceled_shares;

    add_order_decoder u_add (
        .clk(clk),
        .rst(rst),
        .byte_in(byte_in),
        .valid_in(valid_in),
        .add_internal_valid(add_internal_valid),
        .add_packet_invalid(add_packet_invalid),
        .add_order_ref(add_order_ref),
        .add_side(add_side),
        .add_shares(add_shares),
        .add_price(add_price),
        .add_stock_symbol(add_stock_symbol)
    );

    cancel_order_decoder u_cancel (
        .clk(clk),
        .rst(rst),
        .byte_in(byte_in),
        .valid_in(valid_in),
        .cancel_internal_valid(cancel_internal_valid),
        .cancel_packet_invalid(cancel_packet_invalid),
        .cancel_order_ref(cancel_order_ref),
        .cancel_canceled_shares(cancel_canceled_shares)
    );


            // ======================= Waveform Dump =======================
            `ifdef COCOTB_SIM
            initial begin
                $dumpfile("dump.vcd");
                $dumpvars(0, integrated);
            end
            `endif

endmodule
