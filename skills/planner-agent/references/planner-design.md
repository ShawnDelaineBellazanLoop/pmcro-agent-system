# Planner Native MAF Design

## The "Bare Minimum" Philosophy
Complexity leads to logic spirals. To maintain the integrity of the 
PMCRO-VAULT, the Planner must treat every intent as a request for a 
single atomic change.

### Step Decomposition Rules:
1. **Verification First:** Precede state-mutating actions with a read/list check.
2. **Atomic Execution:** Bind to the most direct `domain_action` possible.
3. **No Speculation:** Do not plan for "what-if" scenarios. If a step 
   fails, the Reflector will handle the retry.