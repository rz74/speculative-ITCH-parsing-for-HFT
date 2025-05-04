# compare_helper.py

from helpers.payload_generator_helper import generate_add_order_payload, generate_cancel_order_payload
from helpers.full_workload_helper import MSG_LENGTHS
from sim_config import RESET_CYCLES, SIM_CLK_PERIOD_NS, SIM_HEADERS


def compare_against_expected(recorded_log, expected_events):
    """
    Compares the actual signal log vs expected events, field by field.
    """
    for expected in expected_events:
        cycle = expected["cycle"]
        actual = recorded_log.get(cycle, {})

        for key in SIM_HEADERS:
            if key == "cycle":
                continue  # Skip cycle field

            expected_val = expected.get(key, "")
            actual_val = actual.get(key, "")

            # Only assert if expected value is non-empty
            if expected_val != "":
                assert actual_val == expected_val, (
                    f"Mismatch at cycle {cycle} for '{key}': expected {expected_val}, got {actual_val}"
                )

def generate_expected_events_with_fields(message_plan):
    """
    Generates a list of expected output events per message with matching SIM_HEADERS:
    - Internal valid signal set to 1
    - Parsed fields based on payloads
    - All fields from SIM_HEADERS included in each dict (even if value is blank)

    Returns:
        List[Dict] with unified keys for CSV and comparison
    """
    expected_events = []
    current_cycle = 0

    for msg_type in message_plan:
        msg_len = MSG_LENGTHS[msg_type]
        expected_valid_cycle = current_cycle + msg_len + RESET_CYCLES

        row = {key: "" for key in SIM_HEADERS}
        row["cycle"] = expected_valid_cycle

        if msg_type == "add":
            payload = generate_add_order_payload()
            row["add_internal_valid"] = 1
            row["add_order_ref"] = hex(int.from_bytes(payload[1:9], byteorder='big'))
            row["add_side"] = hex(0) if payload[9] == ord('B') else hex(1)
            row["add_shares"] = hex(int.from_bytes(payload[10:14], byteorder='big'))
            row["add_price"] = hex(int.from_bytes(payload[22:26], byteorder='big'))

        elif msg_type == "cancel":
            payload = generate_cancel_order_payload()
            row["cancel_internal_valid"] = 1
            row["cancel_order_ref"] = hex(int.from_bytes(payload[1:9], byteorder='big'))
            row["cancel_shares"] = hex(int.from_bytes(payload[9:13], byteorder='big'))

        expected_events.append(row)
        current_cycle += msg_len

    return expected_events