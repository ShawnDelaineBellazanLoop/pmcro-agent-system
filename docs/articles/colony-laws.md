---
title: Colony Laws
uid: articles.colony-laws
---

# Colony Laws

Colony Laws are inviolable constraints honored by all agents in every PMCR-O cycle. They are declared in `.pmcro/laws/` and enforced by the Checker's mandatory conflict gates.

---

## EC-SYS-001 — Atomic File Protocol

**Statement:** Every output involving file creation must provide the **entire file content** in a single block. No fragments, no stubs, no placeholder sections.

**Enforced by:** Checker — `FILE_COMPLETENESS` gate  
**Violations:** Any output containing `// TODO`, `// ...`, `/* stub */`, or truncated content fails Checker unconditionally

**Rationale:** Partial file outputs corrupt the target repository state. A file either exists in its final form or it does not exist. There is no intermediate.

**Example — VIOLATION:**
```python
def process():
    # TODO: implement this
    pass
```

**Example — COMPLIANT:**
```python
def process(target: str, dry_run: bool = False) -> tuple[bool, str]:
    if dry_run:
        return True, f"[DRY RUN] Would process: {target}"
    result = _do_work(target)
    return result.success, result.message
```

---

## EC-SYS-002 — Minimalist Planning (One File Per Cycle)

**Statement:** Each PMCR-O cycle produces **exactly one file**. Multi-file intents decompose into sequential cycles; all but the first file are queued as "Pending Next Cycle."

**Enforced by:** Planner (SCOPE-LOCK rule) + Orchestrator (cycle counter)  
**Violations:** Planner frames referencing more than one output file are rejected by Checker

**Rationale:** Minimalist decomposition prevents context window exhaustion, keeps each cycle auditable, and ensures the trail record maps 1:1 with outputs.

**Planning pattern:**
```
Intent: "Create SKILL.md, domain_config.json, and build.ps1 for new-agent"

Cycle 1 → SKILL.md             ← execute now
Cycle 2 → domain_config.json   ← pending next cycle
Cycle 3 → build.ps1            ← pending next cycle
```

---

## GTDDD-MANDATE — Token Substitution (No Hardcoded Identity)

**Statement:** All generated files must use `{{token}}` placeholders for identity-bearing values. Hardcoded company names, author names, URLs, or environment paths are forbidden.

**Enforced by:** Maker (token injection at write time) + Checker (`HARDCODED_IDENTITY` gate)  
**Token source:** `.pmcro/identity.json`

**Core tokens:**

| Token | Resolved From | Example Value |
|:------|:-------------|:--------------|
| `{{company}}` | `identity.json → company` | Tooensure LLC |
| `{{author}}` | `identity.json → author` | Shawn |
| `{{project}}` | `identity.json → project` | pmcro-agent-system |
| `{{repo_url}}` | `identity.json → repo_url` | github.com/{{company}}/... |
| `{{namespace}}` | `identity.json → namespace` | Tooensure.Pmcro |

**Example — VIOLATION:**
```json
{ "company": "Tooensure LLC", "author": "Shawn" }
```

**Example — COMPLIANT (template):**
```json
{ "company": "{{company}}", "author": "{{author}}" }
```

**Resolved at runtime by `PmcroSkillLoader`** via `.template.config/template.json` token substitution.

---

## Derived Laws (Enforced by Specific Agents)

These derive from the core three but are phase-specific:

| Law | Agent | Rule |
|:----|:------|:-----|
| **SCOPE-LOCK** | Planner | Only the first file of a multi-file intent is planned per cycle |
| **CONSTRAINT-PRECHECK** | Planner | `.pmcro/constraints/` must be scanned before any plan is certified |
| **FILE_EXISTS_CONFLICT** | Checker | If output path already has a file, block scoring — do not overwrite silently |
| **PATH_MISSING_CONFLICT** | Checker | If target directory doesn't exist, block scoring — directory must be created first |
| **EARNED-CONSTRAINT-IMMEDIATE** | Reflector | EarnedConstraints are written to disk immediately on hard conflict, not deferred |
| **MAAI-001** | Orchestrator | TYPE1 (state-mutating) actions require HIL (Human-in-the-Loop) authorization token |
| **MAXLOOPS-3** | Orchestrator | Hard stop after 3 RETRY cycles; escalates to HALT with EarnedConstraint |
