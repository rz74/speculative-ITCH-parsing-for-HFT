# =============================================
# payload_generator_helper.py
# =============================================

# Description: ITCH-compliant payload generators for valid test inputs.
# Author: RZ
# Start Date: 04172025
# Version: 0.3

# Changelog
# =============================================
# [20250427-1] RZ: Initial Add/Cancel payloads (from payload_generators.py).
# [20250428-2] RZ: Added Delete/Replace and dummy payload generators.
# [20250429-1] RZ: Adopted into payload_generator_helper.py from payload_generators.py.
# =============================================

def generate_add_order_payload(index=0):
    return bytes([0x41]) + index.to_bytes(8, 'big') + b'B' + (100).to_bytes(4, 'big') + b'ABCDE123' + (1234500).to_bytes(4, 'big')

def generate_cancel_order_payload(index=0):
    return bytes([0x58]) + index.to_bytes(8, 'big') + (50).to_bytes(4, 'big')

def generate_delete_order_payload(index=0):
    return bytes([0x44]) + index.to_bytes(8, 'big')

def generate_replace_order_payload(index=0):
    return bytes([0x55]) + index.to_bytes(8, 'big') + (index+1).to_bytes(8, 'big') + (200).to_bytes(4, 'big') + (1250000).to_bytes(4, 'big')

def generate_dummy_payload(index=0):
    return bytes([0x5A]) + index.to_bytes(8, 'big') + b'BADINPUT'
