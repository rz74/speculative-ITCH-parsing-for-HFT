import random
import itertools
from ITCH_config import MSG_LENGTHS

def generate_msg_sequence(length, weights=None):
    """
    Generate a random message sequence of a given length.

    Args:
        length (int): Number of messages in the sequence.
        weights (dict, optional): A dictionary of message type probabilities.
                                  Keys must match MSG_LENGTHS.

    Returns:
        list: A list of randomly selected message types.
    """
    message_types = list(MSG_LENGTHS.keys())
    
    # Use uniform weights by default
    if weights is None:
        weights = {msg: 1 for msg in message_types}

    # Normalize weights
    total_weight = sum(weights[msg] for msg in message_types)
    probabilities = [weights[msg] / total_weight for msg in message_types]

    return random.choices(message_types, weights=probabilities, k=length)

def generate_permutation_coverage_sequence(shuffle=False):
    """
    Generate a sequence that covers all permutations of the 6 message types exactly once.

    Args:
        shuffle (bool): If True, shuffles the order of permutations.

    Returns:
        list: A list of message types covering all permutations.
    """
    message_types = list(MSG_LENGTHS.keys())
    all_perms = list(itertools.permutations(message_types))

    if shuffle:
        random.shuffle(all_perms)

    # Flatten list of permutations
    flat_sequence = [msg for perm in all_perms for msg in perm]
    return flat_sequence

 
 

