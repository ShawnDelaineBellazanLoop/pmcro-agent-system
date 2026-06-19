---
title: Filesystem Agent
uid: agents.filesystem-agent
---

# filesystem-agent

**Type:** SUBJECT · **Tier:** EXECUTION · **Capability:** DOMAIN_CONFIG_PROVIDER

Domain specialist for file I/O operations on the ReFS DevDrive (S:\). Provides `domain_config.json` declaring the file operation vocabulary consumed by PHASE agents.

---

## Domain Actions

| Action | Type | Description |
|:-------|:-----|:------------|
| `fs_write_file` | TYPE1 | Write a complete file to a target path |
| `fs_zip` | TYPE1 | Archive files or directories to a zip |
| `fs_delete` | TYPE1 | Delete file, directory, or glob-filtered set |

All actions are TYPE1 (HIL-Gated) — require MAAI-001 authorization token.

---

## Scripts

| Script | Description |
|:-------|:------------|
| `scripts/delete_util.py` | Delete single file, directory tree, or glob-filtered set with optional backup |

**Usage:**

```powershell
cd S:\skills\filesystem-agent

# Delete single file
python scripts\delete_util.py --target S:\skills\registry.yaml

# Delete log files (dry run)
python scripts\delete_util.py --target S:\logs --pattern "*.log" --dry-run

# Delete with backup
python scripts\delete_util.py --target S:\old-agent --backup-dir S:\backups
```

---

## MCP Exposure

`filesystem-agent` exposes its domain actions as MCP tool endpoints, discoverable by PHASE agents at runtime:

```
MCP Server: http://localhost:5010
Tools: fs_write_file, fs_zip, fs_delete
```

---

## SKILL.md Location

`S:\skills\filesystem-agent\SKILL.md`
