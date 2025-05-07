// =============================================
// itch_abort_on_valid_drop.vh
// =============================================
// Aborts decoding if valid_in drops mid-packet or byte_index overflows.
// Resets byte_index and suppression count to prepare for next message.
// =============================================

if (`is_order && (
    (valid_in == 0 && byte_index > 0 && byte_index < MSG_LENGTH) ||
    (byte_index >= MSG_LENGTH)
)) begin
    `packet_invalid <= 1;
    suppress_count  <= 0;   // Allow immediate restart
    byte_index      <= 0;
end
