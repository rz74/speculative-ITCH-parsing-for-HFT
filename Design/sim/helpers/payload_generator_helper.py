# =============================================
# payload_generator_helper.py
# =============================================

# Description: ITCH-compliant payload generators for valid test inputs.
# Author: RZ
# Start Date: 04172025
# Version: 0.9

# Changelog
# =============================================
# [20250427-1] RZ: Initial Add/Cancel payloads (from payload_generators.py).
# [20250428-2] RZ: Added Delete/Replace and dummy payload generators.
# [20250429-1] RZ: Adopted into payload_generator_helper.py from payload_generators.py.
# [20250429-2] RZ: Added random_valid_payload() for randomized test cases.
# [20250501-1] RZ: updated cancel_order_payload to provide unused bytes for testing for real applications
# [20250501-2] RZ: updated delete_order_payload.
# [20250501-3] RZ: updated replace_order_payload.
# [20250501-4] RZ: updated executed_order_payload.
# [20250501-5] RZ: updated trade_payload.
# =============================================

import random

def generate_add_order_payload(index=0):
    payload = bytearray(36)
    payload[0] = ord('A')  # Message Type

    # Order Reference
    payload[1:9] = (0x1234567800000000 + index).to_bytes(8, 'big')

    # Buy/Sell Indicator
    payload[9] = ord('S') if index % 2 else ord('B')

    # Shares
    payload[10:14] = (1000 + index).to_bytes(4, 'big')

    # Stock Symbol (left-padded to 8 bytes)
    symbol = f"STK{index}".ljust(8)
    payload[14:22] = symbol.encode('ascii')

    # Price (e.g. $123.45 → 1234500)
    payload[22:26] = (1234500 + index * 10).to_bytes(4, 'big')

    return payload

def generate_cancel_order_payload(index=0):
    payload = bytearray(23)
    payload[0] = ord('X')  # Cancel Order

    payload[1:9] = (0xABCDEF0000000000 + index).to_bytes(8, 'big')   # Order Ref
    payload[9:13] = (500 + index).to_bytes(4, 'big')                 # Shares
    # Fill unused 13–22 with junk
    payload[13:23] = bytes([0xAA] * 10)   
    # payload[13:] = b'\x00' * (23 - 13)                               # Reserved padding

    return payload

def generate_delete_order_payload(index=0):
    """Generate a valid 9-byte Delete Order ('D') ITCH packet"""
    payload = bytearray(9)
    payload[0] = ord('D')  # Message Type
    payload[1:9] = (0x1234567800000000 + index).to_bytes(8, 'big')  # Order Ref
    return payload

def generate_replace_order_payload(index=0):
    """Generate a valid 25-byte Replace Order ('U') ITCH packet"""
    payload = bytearray(25)
    payload[0] = ord('U')  # Message Type
    payload[1:9] = (0xAAAABBBB00000000 + index).to_bytes(8, 'big')   # Old Order Ref
    payload[9:17] = (0xCCCCDDDD00000000 + index).to_bytes(8, 'big')  # New Order Ref
    payload[17:21] = (1000 + index).to_bytes(4, 'big')               # Shares
    payload[21:25] = (1234500 + index * 10).to_bytes(4, 'big')       # Price
    return payload

def generate_executed_order_payload(index=0):
    """Generate a valid 31-byte Executed Order ('E') ITCH packet"""
    payload = bytearray(31)
    payload[0] = ord('E')  # Message Type
    payload[1:9] = (0x1000000000000000 + index).to_bytes(8, 'big')     # Order Ref
    payload[9:13] = (100 + index).to_bytes(4, 'big')                   # Executed Shares
    payload[13:21] = (0xABCDEF0000000000 + index).to_bytes(8, 'big')   # Match ID
    payload[21:25] = (123456789 + index).to_bytes(4, 'big')           # Timestamp
    # [25:31] Reserved — leave as zeros
    return payload

def generate_trade_payload(index=0):
    """Generate a valid 44-byte Trade ('P') ITCH packet"""
    payload = bytearray(44)
    payload[0] = ord('P')  # Message Type
    payload[1:9] = (0x9000000000000000 + index).to_bytes(8, 'big')       # Order Ref
    payload[9:13] = (500 + index).to_bytes(4, 'big')                     # Shares
    payload[13:21] = (0xABC0000000000000 + index).to_bytes(8, 'big')     # Match ID
    payload[21:29] = b"TSLA    "                                         # Symbol (8 bytes, space-padded)
    payload[29:33] = (100000 + index * 5).to_bytes(4, 'big')             # Price
    payload[33:37] = (98765432 + index).to_bytes(4, 'big')               # Timestamp
    # [37:44] Reserved — leave as 0
    return payload


