module payload_dispatcher #(
    parameter PAYLOAD_WIDTH = 512
)(
    input  wire        clk,
    input  wire        rst_n,

    input  wire        in_valid,
    input  wire [7:0]  msg_type,
    input  wire [PAYLOAD_WIDTH-1:0] payload,

    output reg         add_order_valid,
    output reg [PAYLOAD_WIDTH-1:0] add_order_payload
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            add_order_valid   <= 1'b0;
            add_order_payload <= {PAYLOAD_WIDTH{1'b0}};
        end else begin
            add_order_valid   <= 1'b0;
            add_order_payload <= {PAYLOAD_WIDTH{1'b0}};
            if (in_valid) begin
                if (msg_type == 8'h41) begin  // ASCII 'A'
                    add_order_valid   <= 1'b1;
                    add_order_payload <= payload;
                end
            end
        end
    end

endmodule