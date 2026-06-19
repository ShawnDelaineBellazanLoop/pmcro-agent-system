---
title: Planner Agent
uid: agents.planner-agent
---

# planner-agent

**Type:** PHASE · **Tier:** ORCHESTRATION · **Capability:** STRATEGY_GENERATION  
**KernelPlugin:** `PmcroPlannerPlugin` · **KernelFunction:** `DecomposeIntent`

Cognitive strategy architect. Decomposes intents into minimalist executable steps bound to the active subject agent's `domain_config.json` vocabulary. Sole source of certified `PlannerFrame` objects.

---

## Responsibilities

- **Intent decomposition** — maps raw intent to domain_action vocabulary
- **Constraint pre-check** — scans `.pmcro/constraints/` before certifying any plan
- **Risk classification** — classifies every action as TYPE1 (HIL-Gated) or TYPE2 (autonomous)
- **SCOPE-LOCK** — plans exactly one file per cycle; queues remainder as "Pending Next Cycle"
- **domain_config binding** — sole authority mapping intent to subject agent action vocabulary

---

## MAF Contract

```csharp
[KernelFunction("DecomposeIntent")]
[Description("Decomposes intent into a domain-bound PlannerFrame. Returns JSON.")]
public Task<PlannerFrame> DecomposeIntentAsync(string request);
```

---

## Laws Enforced

| Law | Rule |
|:----|:-----|
| **EC-SYS-001** | Plans only for complete file outputs — never stubs or fragments |
| **EC-SYS-002 / SCOPE-LOCK** | One file per cycle; excess is queued |
| **CONSTRAINT-PRECHECK** | `.pmcro/constraints/` must be scanned before certification |
| **GTDDD-MANDATE** | Plans must reference `{{token}}` paths, not hardcoded values |

---

## SKILL.md Location

`S:\skills\planner-agent\SKILL.md`
