---
title: Git Agent
uid: agents.git-agent
---

# git-agent

**Type:** SUBJECT · **Tier:** EXECUTION · **Capability:** DOMAIN_CONFIG_PROVIDER

Domain specialist for version control operations. Provides `domain_config.json` declaring git action vocabulary for the PMCR-O loop.

---

## Domain Actions

| Action | Type | Description |
|:-------|:-----|:------------|
| `git_commit` | TYPE1 | Stage and commit changes with a message |
| `git_branch` | TYPE1 | Create or switch to a branch |
| `git_push` | TYPE1 | Push branch to remote |
| `git_tag` | TYPE1 | Create an annotated tag |

All actions are TYPE1 (HIL-Gated) — remote state mutations require MAAI-001 authorization.

---

## MCP Exposure

```
MCP Server: http://localhost:5011
Tools: git_commit, git_branch, git_push, git_tag
```

---

## SKILL.md Location

`S:\skills\git-agent\SKILL.md`
