# SKILL.template.md — Declarative Skill Manifest Template
# Colony: {{colony_name}} · Schema: 2.0 · Template Version: 2.0.0
# ============================================================
# USAGE: Load this file, replace ALL {{token}} values, validate
# schema 2.0 frontmatter, then write the complete output as the
# new agent's SKILL.md. NEVER output a file with unreplaced tokens.
# ============================================================

---
name: "{{agent_name}}"
schema_version: "2.0"

description: "{{agent_short_description}}"
long_description: >
  {{agent_long_description}}

identity:
  agent_type: "{{agent_type}}"          # PHASE | SUBJECT | SUPPORT
  tier: "{{maf_tier}}"                  # ORCHESTRATION | EXECUTION | INTERPRETATION
  capability_class: "{{capability_class}}"
  owner: "{{company}}"
  colony: "{{colony_name}}"

maf:
  version: "1.10.0"
  triangle_role: "{{triangle_role}}"    # INTERPRETATION | ORCHESTRATION | EXECUTION
  kernel_plugin: "{{kernel_plugin}}"
  kernel_function: "{{kernel_function}}"

runtime:
  model_class: "{{model_class}}"        # FRONTIER | BALANCED | FAST
  latency_budget_ms: {{latency_budget_ms}}
  cost_sensitivity: "{{cost_sensitivity}}"
  risk_level: "{{risk_level}}"
  max_loops: {{max_loops}}
  identity_file: "identity.json"
  domain_config: "{{domain_config_path}}"
  prompt_index: "prompts/prompt_index.json"

laws:
  - { id: "EC-SYS-001", name: "Atomic File Protocol",  rule: "Every output MUST be a complete file. No stubs, no fragments." }
  - { id: "EC-SYS-002", name: "Minimalist Planning",   rule: "ONE file per PMCR-O cycle. Multi-file intents queue across cycles." }
  - { id: "GTDDD-MANDATE", name: "Token Hygiene",      rule: "Zero hardcoded identity. All company/env values use {{token}} syntax." }
  - { id: "{{law_id}}", name: "{{law_name}}", rule: "{{law_rule}}" }

versioning:
  skill_version: "{{skill_version}}"
  maf_version: "1.10.0"
  colony_version: "{{colony_version}}"
  changelog: "meta/changelog.md"
---

# {{agent_display_name}} — {{capability_class}}

> **Colony:** `{{colony_name}}` · **Tier:** `{{maf_tier}}` · **Triangle Role:** `{{triangle_role}}`

{{agent_long_description}}

---

## ⚖️ Colony Laws

| Law ID | Name | Rule |
|:-------|:-----|:-----|
| EC-SYS-001 | Atomic File Protocol | Every output MUST be a complete file. No stubs, no fragments. |
| EC-SYS-002 | Minimalist Planning | ONE file per PMCR-O cycle. Multi-file intents queue. |
| GTDDD-MANDATE | Token Hygiene | Zero hardcoded identity — all values via `{{token}}` substitution. |
| {{law_id}} | {{law_name}} | {{law_rule}} |

---

## 🏗️ PMCR-O Phase Identity

| Phase | Role | This Agent's Action |
|:------|:-----|:--------------------|
| **P** | Planner   | {{phase_p_action}} |
| **M** | Maker     | {{phase_m_action}} |
| **C** | Checker   | {{phase_c_action}} |
| **R** | Reflector | {{phase_r_action}} |

---

## 🔑 Authorities

{{authorities_block}}

---

## 🔗 MAF Integration

**KernelFunction Contract:**
```csharp
[KernelFunction("{{kernel_function}}")]
[Description("{{kernel_function_description}}")]
{{kernel_function_signature}}
```

**Triangle Data Flow:**
```
INTERPRETATION → ORCHESTRATION → EXECUTION → ORCHESTRATION
```

---

## 📁 Skill Package Layout

```
skills/{{agent_name}}/
├── SKILL.md
├── domain_config.json          (SUBJECT agents only)
├── prompts/
│   ├── prompt_index.json
│   ├── system.prompt.md
│   ├── developer.prompt.md
│   ├── user.prompt.md
│   ├── o-mode-optimize.prompt.md
│   ├── o-mode-output.prompt.md
│   ├── o-mode-orchestrate.prompt.md
│   └── o-mode-topology.prompt.md
├── references/
│   ├── versions.md
│   ├── patterns.md
│   ├── constraints.md
│   ├── security.md
│   └── observability.md
├── scripts/
│   └── validate.ps1
├── evals/
│   ├── smoke_test.md
│   ├── eval_matrix.md
│   └── regression.md
├── assets/
└── meta/
    ├── changelog.md
    ├── policy.json
    ├── ownership.md
    └── deprecation.md
```
