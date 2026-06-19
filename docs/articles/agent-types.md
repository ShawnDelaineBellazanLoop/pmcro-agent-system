---
title: Agent Types & Tiers
uid: articles.agent-types
---

# Agent Types & Tiers

The Colony organizes agents into two classification axes: **type** (structural role) and **tier** (MAF triangle position).

---

## Agent Types

### PHASE Agents

PHASE agents implement the four cognitive phases of the PMCR-O loop. They are always active — every cycle passes through all four in sequence.

| Agent | Phase | KernelFunction | Output Frame |
|:------|:------|:--------------|:-------------|
| `planner-agent` | P | `DecomposeIntent` | `PlannerFrame` |
| `maker-agent` | M | `ExecutePlan` | `MakerFrame` |
| `checker-agent` | C | `ValidateOutput` | `CheckerFrame` |
| `reflector-agent` | R | `IssueVerdict` | `ReflectorVerdict` |

PHASE agents do not own domain_config — they consume it from the active SUBJECT agent.

### SUBJECT Agents

SUBJECT agents are domain specialists. Each one owns a `domain_config.json` that declares the vocabulary of actions it can perform. The Orchestrator activates exactly one SUBJECT agent per cycle.

| Agent | Domain | Capability | Actions |
|:------|:-------|:-----------|:--------|
| `filesystem-agent` | File I/O | `DOMAIN_CONFIG_PROVIDER` | fs_write_file, fs_zip, fs_delete |
| `git-agent` | Version control | `DOMAIN_CONFIG_PROVIDER` | git_commit, git_branch, git_push, git_tag |
| `docfx-agent` | Documentation | `DOCUMENTATION_AUTOMATION` | scaffold, build, serve, validate, publish |

SUBJECT agents are passive — they expose a `domain_config.json` and optional `scripts/` but do not invoke the LLM directly. The PHASE agents consume their config.

### SUPPORT Agents

SUPPORT agents operate outside the PMCR-O loop. They are provisioners, architects, and meta-level tools that build and maintain the Colony itself.

| Agent | Role | Capability |
|:------|:-----|:-----------|
| `orchestrator-agent` | Loop controller | `LOOP_CONTROLLER` |
| `skill-maker-agent` | Package provisioner | `RECURSIVE_PROVISIONER` |

> Note: `orchestrator-agent` carries a dual classification — it is both a PHASE agent wrapper (the "O" in PMCR-O) and the SUPPORT/ORCHESTRATION tier controller.

---

## MAF Tiers

Each agent is assigned a `maf_tier` that maps to the Microsoft Agent Framework triangle:

```
        ┌────────────────────────────────────┐
        │         ORCHESTRATION TIER          │
        │  orchestrator · planner · reflector │
        │  skill-maker-agent                  │
        └─────────────────┬──────────────────┘
                          │ routes
        ┌─────────────────▼──────────────────┐
        │           EXECUTION TIER            │
        │  maker · checker                    │
        │  filesystem · git · docfx           │
        └────────────────────────────────────┘
```

| `maf_tier` | Triangle Role | Agents |
|:-----------|:-------------|:-------|
| `ORCHESTRATION` | Intent classification, routing, arbitration | orchestrator, planner, reflector, skill-maker |
| `EXECUTION` | Action dispatch, validation, domain operations | maker, checker, filesystem, git, docfx |

---

## Skill Package Structure

Every agent lives in `S:\skills\<agent-name>\` with the following standard layout:

```
<agent-name>\
├── SKILL.md               # Agent identity, laws, MAF contract (REQUIRED)
├── domain_config.json     # Vocabulary of domain_actions (SUBJECT agents)
├── references\            # Reference docs for LLM context
│   ├── versions.md        # Validated package versions
│   └── *.md               # Additional reference material
├── scripts\               # Executable helpers
│   ├── build.ps1          # (docfx-agent, etc.)
│   └── *.py / *.ps1
├── evals\                 # Evaluation suites
│   └── smoke_test.md
└── assets\                # Templates, examples
    └── *.md
```

`SKILL.md` is the single required file. All others are additive.

---

## Registry

All agents are registered in `S:\registry.yaml`. The `load_order` array determines the sequence in which the `PmcroSkillLoader` advertises skills during Stage 1 (Advertise) of the loop lifecycle.

See [Skill Registry](registry.md) for the full registry reference.
