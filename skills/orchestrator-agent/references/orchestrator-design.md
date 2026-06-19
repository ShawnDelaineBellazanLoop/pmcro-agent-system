# Orchestrator Native MAF Design

## Minimalist Single-File Constraint
To prevent context drift and ensure ReFS volume integrity, this agent is 
hard-coded to enforce **one file per cycle**. 

### Workflow for multi-file requests:
1. Orchestrator detects intent for File A and File B.
2. Planner creates strategic steps ONLY for File A.
3. Maker produces File A.
4. Reflector closes cycle.
5. Orchestrator prompts user: "File A complete. Shall I proceed to File B?"