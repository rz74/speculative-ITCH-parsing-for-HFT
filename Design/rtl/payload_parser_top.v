// ------------------------------------------------------------------------------------------------
// Architecture Notes:
// ------------------------------------------------------------------------------------------------
//
// High-frequency trading systems typically ingest raw ITCH feeds over 10G/25G Ethernet using
// a dedicated MAC + TCP/IP stack implemented in FPGA logic or via an ultra-low-latency NIC.
// Incoming Ethernet frames contain multiple concatenated ITCH messages.
//
// A lightweight framing unit extracts and aligns individual ITCH messages, which are streamed
// as 8-bit serialized data (`byte_in`) with accompanying `valid_in` signal. This format mimics
// an AXI-lite-style streaming interface and allows the downstream decoder to begin parsing 
// immediately without waiting for the full message.