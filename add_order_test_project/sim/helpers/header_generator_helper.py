# =============================================
# header_generator_helper.py
# =============================================

# Description: Utilities for generating valid and randomized ITCH message headers.
# Author: RZ
# Start Date: 20250429
# Version: 0.5

# Changelog
# =============================================
# [20250429-1] RZ: Initial version with generate_header() and generate_random_header().
# [20250429-2] RZ: Added generate_invalid_header() for malformed test cases.
# [20250429-3] RZ: Integrated into test_header_parser.py for structured header generation.
# [20250429-4] RZ: Added generate_random_valid_header() for randomized valid header generation.
# [20250429-5] RZ: Refactored to ensure valid header generation with known ITCH message types.
# =============================================

import random

def generate_header(msg_type: str, length: int) -> bytes:
    """Generate a valid ITCH header with given message type and length."""
    assert len(msg_type) == 1, "msg_type must be a single ASCII character"
    assert 0 <= length <= 65535, "length must be between 0 and 65535"
    return msg_type.encode() + length.to_bytes(2, byteorder='big')

def generate_random_header() -> bytes:
    """Generate a randomized ITCH header with common message types."""
    msg_type = random.choice(b'AXDUZ')  # Common ITCH types + dummy
    length = random.randint(1, 255)     # Reasonable message length
    return bytes([msg_type]) + length.to_bytes(2, byteorder='big')

def generate_invalid_header() -> bytes:
    """Generate an intentionally malformed ITCH header."""
    invalid_msg_type = bytes([random.randint(0x80, 0xFF)])  # Non-ASCII or reserved type
    invalid_length = random.choice([0, 0xFFFF, 99999])      # Zero or excessive length
    length_bytes = (invalid_length & 0xFFFF).to_bytes(2, byteorder='big')
    return invalid_msg_type + length_bytes

def generate_random_valid_header() -> bytes:
    """Generate a valid header with a random known ITCH msg_type and reasonable length."""
    valid_types = b'AXDU'  # Valid ITCH message types
    msg_type = random.choice(valid_types)
    length = random.randint(16, 64)  # Reasonable ITCH payload length range
    return generate_header(chr(msg_type), length)


