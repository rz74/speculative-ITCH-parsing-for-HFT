# helpers/full_workload_helper.py
from sim_config import SIM_CLK_PERIOD_NS, MSG_LENGTHS


from .payload_generator_helper import  generate_add_order_payload, generate_cancel_order_payload, generate_delete_order_payload, generate_replace_order_payload, generate_executed_order_payload, generate_trade_payload


def generate_payload_by_type(msg_type, mode='set'):
    if msg_type == 'add':
        return generate_add_order_payload(mode)
    elif msg_type == 'cancel':
        return generate_cancel_order_payload(mode)
    elif msg_type == 'delete':
        return generate_delete_order_payload(mode)
    elif msg_type == 'replace':
        return generate_replace_order_payload(mode)
    elif msg_type == 'executed':
        return generate_executed_order_payload(mode)
    elif msg_type == "trade":
        return generate_trade_payload(mode)


    else:
        raise ValueError(f"Unsupported message type: {msg_type}")
# def generate_payload_by_type(msg_type: str, mode: str = "set"):
#     if msg_type == "add":
#         return generate_add_order_payload(mode)
#     elif msg_type == "cancel":
#         return generate_cancel_order_payload(mode)
 
#     else:
#         raise ValueError(f"Unknown message type: {msg_type}")


def run_full_payload_workload(message_plan):
    """
    Generates a full ITCH message stream and logs timing info.

    Args:
        message_plan: list of message types like ["add", "cancel", "add", ...]

    Returns:
        {
            'full_stream': List[int],
            'injection_schedule': List[Dict] with keys:
                'type', 'start_cycle', 'start_time_ns', 'expected_valid_cycle'
        }
    """
    full_stream = []
    injection_schedule = []
    RESET_CYCLES = 3
    current_cycle = RESET_CYCLES


    for msg_type in message_plan:
        payload = generate_payload_by_type(msg_type, mode="set")
        msg_len = len(payload)

        injection_schedule.append({
            "type": msg_type,
            "start_cycle": current_cycle,
            "start_time_ns": current_cycle * SIM_CLK_PERIOD_NS,
            "expected_valid_cycle": current_cycle + MSG_LENGTHS[msg_type],
        })

        full_stream.extend(payload)
        current_cycle += msg_len

    return {
        "full_stream": full_stream,
        "injection_schedule": injection_schedule,
    }
