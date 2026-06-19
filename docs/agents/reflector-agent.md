---
title: Reflector Agent
uid: agents.reflector-agent
---

# reflector-agent

**Type:** PHASE · **Tier:** ORCHESTRATION · **Capability:** TERMINAL_ARBITRATION  
**KernelPlugin:** `PmcroReflectorPlugin` · **KernelFunction:** `IssueVerdict`

Terminal decision authority. Consumes `CheckerFrame` and issues the loop's terminal disposition: COMPLETE, RETRY, or HALT. Writes EarnedConstraints immediately on hard conflicts.

---

## Responsibilities

- **Terminal disposition** — sole authority issuing COMPLETE / RETRY / HALT
- **EarnedConstraint authoring** — writes constraints to `.pmcro/constraints/` immediately on HALT
- **Trail trigger** — signals trail write on every disposition (trails are always written)
- **Fault deferral** — handles faults in the next iteration; never mid-cycle

---

## MAF Contract

```csharp
[KernelFunction("IssueVerdict")]
[Description("Issues terminal loop disposition from CheckerFrame. Returns ReflectorVerdict JSON.")]
public Task<ReflectorVerdict> IssueVerdictAsync(string checkerFrameJson);
```

---

## Disposition Table

| Disposition | Trigger | Consequence |
|:------------|:--------|:------------|
| `COMPLETE` | `CheckerFrame.passed == true` | Trail written; outputs promoted; loop ends |
| `RETRY` | Score < 0.85, no hard conflict | EarnedConstraint injected; Planner re-runs |
| `HALT` | Hard conflict OR MaxLoops reached | EarnedConstraint written to disk immediately; loop terminated |

---

## EarnedConstraint Rule

EarnedConstraints are written **immediately** on HALT — not deferred, not batched. The Planner must honor all active constraints in the next cycle. Constraints remain active until manually resolved.

---

## SKILL.md Location

`S:\skills\reflector-agent\SKILL.md`
