# Git-Agent: Workflow Patterns

## Standard PMCR-O Integration

### After Successful Checker Pass
1. Check status
2. Stage changes
3. Commit with structured message

```bash
git status
git add .
git commit -m "PMCR-O Cycle X - [Goal] - Checker Approved
Details: [key changes]"
```