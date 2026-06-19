---
title: Skill Registry
uid: articles.registry
---

# Skill Registry

The master skill registry lives at `S:\registry.yaml`. It is the single source of truth for all agent packages in the Colony.

---

## Schema

```yaml
schema_version: "1.0"
manifest_version: "4.6.0"
company: "{{company}}"

load_order:          # Stage 1 (Advertise) load sequence for PmcroSkillLoader
  - agent-name

skills:
  agent-name:
    path: skills/agent-name/SKILL.md
    type: PHASE | SUBJECT | SUPPORT
    tier: ORCHESTRATION | EXECUTION
    capability: CAPABILITY_CLASS
    version: "1.0.0"
    provisioned_by: skill-maker-agent
    provisioned_at: "YYYY-MM-DD"

storage:
  root: "S:/"
  skills_dir: "skills/"
  trails_dir: ".pmcro/trails/"
  backups_dir: "backups/"
```

---

## Registered Agents (v4.6.0)

| # | Agent | Type | Tier | Capability |
|:--|:------|:-----|:-----|:-----------|
| 1 | `orchestrator-agent` | PHASE | ORCHESTRATION | LOOP_CONTROLLER |
| 2 | `planner-agent` | PHASE | ORCHESTRATION | STRATEGY_GENERATION |
| 3 | `maker-agent` | PHASE | EXECUTION | EXECUTION_ENGINE |
| 4 | `checker-agent` | PHASE | EXECUTION | VALIDATION_GATE |
| 5 | `reflector-agent` | PHASE | ORCHESTRATION | TERMINAL_ARBITRATION |
| 6 | `filesystem-agent` | SUBJECT | EXECUTION | DOMAIN_CONFIG_PROVIDER |
| 7 | `git-agent` | SUBJECT | EXECUTION | DOMAIN_CONFIG_PROVIDER |
| 8 | `skill-maker-agent` | SUPPORT | ORCHESTRATION | RECURSIVE_PROVISIONER |
| 9 | `docfx-agent` | SUBJECT | EXECUTION | DOCUMENTATION_AUTOMATION |

---

## Load Order

The `load_order` array controls `PmcroSkillLoader` Stage 1 (Advertise) sequence:

1. `orchestrator-agent` — loaded first; establishes routing authority
2. `planner-agent` — strategy layer
3. `maker-agent` — execution layer
4. `checker-agent` — validation layer
5. `reflector-agent` — arbitration layer
6. `filesystem-agent` — domain: file I/O
7. `git-agent` — domain: version control
8. `skill-maker-agent` — support: provisioner
9. `docfx-agent` — domain: documentation

PHASE agents (1–5) are always loaded. SUBJECT agents (6–9) are loaded on-demand via Progressive Disclosure when their domain is activated.

---

## Adding an Agent

1. Run `/skill-maker-agent` to provision the package under `S:\skills\<new-agent>\`
2. The `skill-maker-agent` will append to `S:\registry.yaml` via `mk_registry_entry`
3. Add the agent to `load_order` at the appropriate position
4. Rebuild the DocFX site: `cd S:\docs && .\scripts\build.ps1`

---

## Canonical Location

`S:\registry.yaml` is the **only** registry file. A duplicate `S:\skills\registry.yaml` was created in error and deleted. Do not recreate it.
