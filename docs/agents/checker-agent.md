---
title: Checker Agent
uid: agents.checker-agent
---

# checker-agent

**Type:** PHASE · **Tier:** EXECUTION · **Capability:** VALIDATION_GATE  
**KernelPlugin:** `PmcroCheckerPlugin` · **KernelFunction:** `ValidateOutput`

Validation gate. Verifies `MakerFrame` against the certified `PlannerFrame`. Runs mandatory conflict gates before scoring. A triggered conflict blocks the score entirely — there is no partial pass.

---

## Responsibilities

- **Conflict gate execution** — runs all mandatory pre-score gates
- **Scoring** — produces a float score (0.0–1.0); threshold 0.85 required to pass
- **Frame verification** — confirms Maker output matches Planner specification
- **Law compliance check** — validates EC-SYS-001, EC-SYS-002, GTDDD-MANDATE in output

---

## MAF Contract

```csharp
[KernelFunction("ValidateOutput")]
[Description("Validates MakerFrame against PlannerFrame. Returns CheckerFrame JSON.")]
public Task<CheckerFrame> ValidateOutputAsync(string makerFrameJson, string plannerFrameJson);
```

---

## Mandatory Conflict Gates (Pre-Score)

| Gate | Trigger | Effect |
|:-----|:--------|:-------|
| `FILE_EXISTS_CONFLICT` | Output path already contains a file | `passed: false` — unconditional |
| `PATH_MISSING_CONFLICT` | Target directory does not exist | `passed: false` — unconditional |
| `FILE_COMPLETENESS` | Output contains stubs/TODOs/truncation | `passed: false` — unconditional |
| `HARDCODED_IDENTITY` | Output contains hardcoded identity values | `passed: false` — unconditional |

**Score threshold:** `>= 0.85` required. Conflicts bypass scoring entirely.

---

## SKILL.md Location

`S:\skills\checker-agent\SKILL.md`
