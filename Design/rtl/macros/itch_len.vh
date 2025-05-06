// ============================================================
// itch_len.vh
// Returns expected ITCH message length based on type
// ============================================================

function automatic logic [5:0] itch_length(input logic [7:0] msg_type);
    case (msg_type)
        "A": return 36;  // Add Order
        "X": return 23;  // Cancel Order
        "U": return 27;  // Replace Order
        "D": return 9;   // Delete Order
        "E": return 30;  // Executed Order
        "P": return 40;  // Trade
        default: return 2; // Catch-all / suppression fallback
    endcase
endfunction
