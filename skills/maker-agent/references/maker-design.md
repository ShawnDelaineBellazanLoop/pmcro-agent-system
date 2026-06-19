# Maker Native MAF Design

## The "Dumb Pipe" Principle
The Maker-Agent is intentionally "dumb." It does not question the 
strategy; it only enforces the **Safety Laws** (TYPE 1 gates) and 
**System Laws** (Atomic writes).

### Execution Discipline:
1. **No Partial Success:** If a multi-step execution fails halfway, the 
   Maker marks the entire `maker_succeeded` field as `false`.
2. **Standard Output:** Every result must be string-serializable for 
   the Checker to read.
3. **Environment Isolation:** The Maker operates within the 
   boundaries of the underlying tool server (MCP).