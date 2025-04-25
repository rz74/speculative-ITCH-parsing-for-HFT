// ============================================================================
// Module: payload_dispatcher
// Purpose: Route incoming ITCH messages to specific decoders based on type.
// Architecture Choice: Instantiates decoders in top module, this module only dispatches.
// Pros: Simple control, parallel decode, industry practice (Jump, MIT HFT project)
// Cons: Slightly higher static resource usage due to multiple always-on decoders.
// ============================================================================

module payload_dispatcher #(
    parameter PAYLOAD_WIDTH = 512  // width of full incoming payload
)(
    input  wire        clk,
    input  wire        rst_n,

    input  wire        in_valid,
    input  wire [7:0]  msg_type,       // 1 byte ITCH message type (ASCII)
    input  wire [PAYLOAD_WIDTH-1:0] payload,

    // Routed outputs to individual decoders
    output reg         add_order_valid,
    output reg [PAYLOAD_WIDTH-1:0] add_order_payload

    // Add more outputs here for other types like cancel/delete...
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            add_order_valid   <= 1'b0;
            add_order_payload <= {PAYLOAD_WIDTH{1'b0}};
        end else begin
            // Default to 0
            add_order_valid   <= 1'b0;
            add_order_payload <= {PAYLOAD_WIDTH{1'b0}};

            if (in_valid) begin
                // ASCII 'A' = 8'h41 → Add Order
                if (msg_type == 8'h41) begin
                    add_order_valid   <= 1'b1;
                    add_order_payload <= payload;
                end
                // Future: add more routes here
            end
        end
    end

endmodule
