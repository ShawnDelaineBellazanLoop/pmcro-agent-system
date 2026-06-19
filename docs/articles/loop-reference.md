---
title: PMCR-O Loop Reference
uid: articles.loop-reference
---

# PMCR-O Loop Reference

Quick-reference for the loop lifecycle, frame schemas, conflict gates, and disposition codes.

---

## Loop Lifecycle Stages

| Stage | Name | Description |
|:------|:-----|:------------|
| 0 | **Bootstrap** | Identity loaded from `.pmcro/identity.json`; constraints scanned |
| 1 | **Advertise** | `PmcroSkillLoader` loads registry in `load_order` sequence |
| 2 | **Route** | Orchestrator resolves subject agent from intent |
| 3 | **Plan** | Planner consumes subject `domain_config.json`; emits `PlannerFrame` |
| 4 | **Execute** | Maker dispatches `domain_actions`; emits `MakerFrame` |
| 5 | **Validate** | Checker runs conflict gates + scoring; emits `CheckerFrame` |
| 6 | **Arbitrate** | Reflector issues terminal disposition |
| 7 | **Trail** | Trail written to `.pmcro/trails/<timestamp>.json` regardless of disposition |

---

## PlannerFrame Schema

```json
{
  "frame_id": "uuid",
  "intent": "string",
  "subject_agent": "agent-name",
  "domain_actions": [
    {
      "action_id": "domain_action_key",
      "type": "TYPE1 | TYPE2",
      "parameters": {},
      "risk_rationale": "string"
    }
  ],
  "constraints_checked": true,
  "active_constraints": ["constraint-id"],
  "certified": true,
  "timestamp": "ISO8601"
}
```

---

## MakerFrame Schema

```json
{
  "frame_id": "uuid",
  "planner_frame_id": "uuid",
  "actions_dispatched": [
    {
      "action_id": "domain_action_key",
      "status": "SUCCESS | FAILED | SKIPPED",
      "output_path": "S:\\path\\to\\file",
      "duration_ms": 42
    }
  ],
  "outputs": [
    { "path": "S:\\path\\to\\file", "size_bytes": 1024 }
  ],
  "execution_time_ms": 250,
  "timestamp": "ISO8601"
}
```

---

## CheckerFrame Schema

```json
{
  "frame_id": "uuid",
  "maker_frame_id": "uuid",
  "conflicts": [
    {
      "gate": "FILE_EXISTS_CONFLICT | PATH_MISSING_CONFLICT | FILE_COMPLETENESS | HARDCODED_IDENTITY",
      "triggered": false,
      "details": "string"
    }
  ],
  "score": 0.92,
  "passed": true,
  "notes": ["string"],
  "timestamp": "ISO8601"
}
```

**Score threshold:** `>= 0.85` required. Conflicts set `passed: false` unconditionally regardless of score.

---

## Conflict Gates (Pre-Score, Mandatory)

| Gate | Condition | Result |
|:-----|:----------|:-------|
| `FILE_EXISTS_CONFLICT` | Output path already contains a file | Block — do not overwrite silently |
| `PATH_MISSING_CONFLICT` | Target directory does not exist | Block — directory must exist first |
| `FILE_COMPLETENESS` | Output contains stubs (`// TODO`, `pass`, etc.) | Block — violates EC-SYS-001 |
| `HARDCODED_IDENTITY` | Output contains hardcoded company/author/path | Block — violates GTDDD-MANDATE |

---

## Reflector Dispositions

| Disposition | Trigger | Action |
|:------------|:--------|:-------|
| `COMPLETE` | Checker passed (score ≥ 0.85, no conflicts) | Trail written; Orchestrator notified; loop ends |
| `RETRY` | Checker failed (score < 0.85, no hard conflicts) | EarnedConstraint injected; Planner re-runs; cycle counter incremented |
| `HALT` | Hard conflict gate triggered OR MaxLoops (3) reached | EarnedConstraint written immediately; loop terminated; escalation flagged |

---

## EarnedConstraint Schema

```json
{
  "constraint_id": "EC-<timestamp>-<hash>",
  "source_cycle": 2,
  "trigger": "FILE_EXISTS_CONFLICT",
  "rule": "Do not write to S:\\path\\to\\file — already exists",
  "applies_to": ["maker-agent"],
  "created_at": "ISO8601",
  "honored_by_cycles": []
}
```

Written to: `.pmcro/constraints/<constraint_id>.json`

---

## Trail Schema

```json
{
  "trail_id": "uuid",
  "intent": "string",
  "subject_agent": "agent-name",
  "cycles": [
    {
      "cycle_number": 1,
      "planner_frame_id": "uuid",
      "maker_frame_id": "uuid",
      "checker_frame_id": "uuid",
      "disposition": "COMPLETE | RETRY | HALT"
    }
  ],
  "final_disposition": "COMPLETE",
  "earned_constraints_written": [],
  "outputs": ["S:\\path\\to\\file"],
  "duration_ms": 4200,
  "timestamp": "ISO8601"
}
```

Written to: `.pmcro/trails/<ISO8601-timestamp>.json`

---

## MaxLoops Policy

Default: **3 cycles**. Configurable in `.pmcro/config.json`:

```json
{
  "loop": {
    "max_cycles": 3,
    "on_max_reached": "HALT"
  }
}
```

When MaxLoops is reached the Reflector issues `HALT`, writes an EarnedConstraint documenting the loop spiral, and the intent is returned to the user for manual resolution.
