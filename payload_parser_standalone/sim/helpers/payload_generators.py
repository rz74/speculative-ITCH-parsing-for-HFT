# =============================================
# payload_generators.py
# =============================================

# Description: Helper utilities to generate ITCH protocol payloads for Add and Cancel Order messages.
# Author: RZ
# Start Date: 04172025
# Version: 0.1

# Changelog
# =============================================
# [20250427-1] RZ: Initial version for Add Order and Cancel Order payload generation.
# [20250428-1] RZ: Improved payload structure padding and added random garbage generator.
# =============================================

def generate_add_order_payload(index):
    payload = bytearray(64)
    payload[0] = ord('A')
    payload[1:9] = (0x1234567800000000 + index).to_bytes(8, 'big')
    payload[9] = ord('B')
    payload[10:14] = (1000 + index).to_bytes(4, 'big')
    payload[14:22] = b"GOOG    "
    payload[22:26] = (100000 + index*10).to_bytes(4, 'big')
    return payload

def generate_cancel_order_payload(index):
    payload = bytearray(64)
    payload[0] = ord('X')
    payload[1:9] = (0xDEADBEEFCAFEBABE + index).to_bytes(8, 'big')
    payload[9:13] = (1000 + index*5).to_bytes(4, 'big')
    return payload