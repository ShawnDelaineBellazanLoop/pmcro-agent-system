# Filesystem-Agent: Tool Usage Patterns

## Core Philosophy
Treat every file and directory in `/home/workdir/artifacts/` (and subdirs) as **persistent artifacts**. Always read before writing/editing.

## Recommended Patterns

### 1. Inventory Artifacts
```bash
ls -la /home/workdir/artifacts/
find /home/workdir/artifacts/ -type f | head -20
```