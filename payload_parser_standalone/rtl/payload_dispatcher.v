// =============================================
// payload_dispatcher.v
// =============================================
//
// Description: Dispatcher module to route ITCH payloads based on message type.
// Author: RZ
// Start Date: 04172025
// Version: 0.1
//
// Changelog
// =============================================
// [20250427-1] RZ: Initial version supporting Add Order ('A') and Cancel Order ('X') dispatching.
// =============================================


module payload_dispatcher #(
    parameter PAYLOAD_WIDTH = 512
)(
    input  wire        clk,
    input  wire        rst_n,

    input  wire        in_valid,
    input  wire [7:0]  msg_type,
    input  wire [PAYLOAD_WIDTH-1:0] payload,

    output reg         add_order_valid,
    output reg [PAYLOAD_WIDTH-1:0] add_order_payload,

    output reg         cancel_order_valid,
    output reg [PAYLOAD_WIDTH-1:0] cancel_order_payload
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            add_order_valid     <= 1'b0;
            add_order_payload   <= {PAYLOAD_WIDTH{1'b0}};
            cancel_order_valid  <= 1'b0;
            cancel_order_payload<= {PAYLOAD_WIDTH{1'b0}};
        end else begin
            add_order_valid     <= 1'b0;
            add_order_payload   <= {PAYLOAD_WIDTH{1'b0}};
            cancel_order_valid  <= 1'b0;
            cancel_order_payload<= {PAYLOAD_WIDTH{1'b0}};
            if (in_valid) begin
                if (msg_type == 8'h41) begin // 'A' Add Order
                    add_order_valid   <= 1'b1;
                    add_order_payload <= payload;
                end else if (msg_type == 8'h58) begin // 'X' Cancel Order
                    cancel_order_valid   <= 1'b1;
                    cancel_order_payload <= payload;
                end
            end
        end
    end

endmodule
