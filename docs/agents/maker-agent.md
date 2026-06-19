---
title: Maker Agent
uid: agents.maker-agent
---

# maker-agent

**Type:** PHASE · **Tier:** EXECUTION · **Capability:** EXECUTION_ENGINE  
**KernelPlugin:** `PmcroMakerPlugin` · **KernelFunction:** `ExecutePlan`

Declarative execution engine. Dispatches `domain_actions` from a certified `PlannerFrame`. Will not execute without a Planner-certified frame.

---

## Responsibilities

- **domain_action dispatch** — executes each action in the `PlannerFrame` against the subject agent's `domain_config.json`
- **Token resolution** — resolves all `{{token}}` placeholders from `.pmcro/identity.json` at write time
- **Output staging** — writes outputs to `.pmcro/generated/<frame_id>/` before Checker validation
- **File promotion** — promotes staged outputs to final paths only after Checker issues COMPLETE

---

## MAF Contract

```csharp
[KernelFunction("ExecutePlan")]
[Description("Executes a certified PlannerFrame. Returns MakerFrame JSON.")]
public Task<MakerFrame> ExecutePlanAsync(string plannerFrameJson);
```

---

## Laws Enforced

| Law | Rule |
|:----|:-----|
| **EC-SYS-001** | Outputs must be complete — Maker never writes partial files |
| **EC-SYS-002** | One file per cycle — Maker dispatches at most one file-write action |
| **GTDDD-MANDATE** | Token substitution applied at write time; no hardcoded values in output |
| **STAGING-FIRST** | All outputs staged in `.pmcro/generated/` before promotion |

---

## SKILL.md Location

`S:\skills\maker-agent\SKILL.md`
