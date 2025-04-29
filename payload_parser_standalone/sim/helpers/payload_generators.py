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
# [20250428-2] RZ: Added Delete Order payload generation.
# [20250428-3] RZ: Added Replace Order payload generation.

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

def generate_delete_order_payload(seed=0):
    """Generate a valid Delete Order ('D') payload."""
    import random
    random.seed(seed)
    payload = bytearray(64)
    payload[0] = ord('D')  # Message Type 'D'
    payload[1:9] = random.getrandbits(64).to_bytes(8, byteorder='big')  # Order Ref

    # The rest of the payload is zero-padded
    return payload

def generate_replace_order_payload(seed=0):
    import random
    random.seed(seed)
    payload = bytearray(64)
    payload[0] = ord('U')
    payload[1:9] = random.getrandbits(64).to_bytes(8, 'big')  # Original Order Ref
    payload[9:17] = random.getrandbits(64).to_bytes(8, 'big')  # New Order Ref
    payload[17:21] = random.getrandbits(32).to_bytes(4, 'big')  # Shares
    return payload
