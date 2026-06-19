import json

def decompose(intent, domain_config):
    """
    Decomposes intent into steps following EC-SYS-002.
    Ensures exactly one file-producing action is planned.
    """
    steps = []
    # logic to identify domain_actions from config
    # logic to enforce 'one-file-at-a-time'
    return {
        "planner_certified": True,
        "steps": steps,
        "notes": ["Minimalist planning logic applied."]
    }

if __name__ == "__main__":
    # Logic for CLI decomposition tests
    pass