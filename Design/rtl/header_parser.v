// =============================================
// header_parser.v
// =============================================
//
// Description: Module to decode header from ITCH payloads and generate start_flag 
//              and payload_valid_out signals.
// Author: RZ
// Start Date: 04292025
// Version: 0.2
//
// Changelog
// =============================================
// [20250429-1] RZ: Initial
// [20250429-2] RZ: Fixed payload_out timing to correctly latch tcp_payload_in.
// =============================================

module header_parser (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [7:0]  tcp_payload_in,
    input  wire        tcp_byte_valid_in,

    output reg         start_flag,        // 1-cycle pulse when a new message starts
    output reg [7:0]   payload_out,        // Forwarded payload byte
    output reg         payload_valid_out   // Valid flag for payload bytes
);

    // Internal FSM state
    typedef enum logic [1:0] {
        IDLE,
        RECEIVING
    } state_t;
    
    state_t state, next_state;

    // State transition
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    // FSM next state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (tcp_byte_valid_in)
                    next_state = RECEIVING;
            end
            RECEIVING: begin
                if (!tcp_byte_valid_in)
                    next_state = IDLE;
            end
        endcase
    end

    // Output logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            start_flag <= 1'b0;
            payload_out <= 8'd0;
            payload_valid_out <= 1'b0;
        end else begin
            // Default output deassertions
            start_flag <= 1'b0;
            payload_valid_out <= 1'b0;

            if (tcp_byte_valid_in) begin
                payload_out <= tcp_payload_in;
                payload_valid_out <= 1'b1;

                if (state == IDLE) begin
                    start_flag <= 1'b1; // Pulse start_flag only on first byte
                end
            end
        end
    end

endmodule
