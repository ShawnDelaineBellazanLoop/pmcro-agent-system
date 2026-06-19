---
title: PMCR-O Architecture
description: The PMCR-O cognitive loop — Planner, Maker, Checker, Reflector, Orchestrator — phase contracts, frame chain, and MAF workflow graph binding.
uid: articles.architecture
---

# PMCR-O Architecture

The Colony implements the **PMCR-O cognitive loop** — a strictly sequential, four-phase agent execution model governed by the Orchestrator.

## The Loop

```
                    ┌──────────────────────────────┐
                    │       ORCHESTRATOR-AGENT       │
                    │   (sole routing authority)     │
                    └──────┬──────────────┬──────────┘
                           │              ▲
                    routes │              │ terminal verdict
                           ▼              │
              ┌──────────────────────────────────────┐
              │            PMCR-O CYCLE               │
              │                                       │
              │  ┌──────────┐    ┌──────────────┐    │
              │  │ PLANNER  │───►│    MAKER     │    │
              │  │          │    │              │    │
              │  │ PlannerFrame  │  MakerFrame  │    │
              │  └──────────┘    └──────┬───────┘    │
              │                         │             │
              │                         ▼             │
              │                  ┌──────────────┐    │
              │                  │   CHECKER    │    │
              │                  │              │    │
              │                  │ CheckerFrame │    │
              │                  └──────┬───────┘    │
              │                         │             │
              │                         ▼             │
              │                  ┌──────────────┐    │
              │                  │  REFLECTOR   │    │
              │                  │              │    │
              │                  │ COMPLETE /   │    │
              │                  │ RETRY / HALT │    │
              │                  └──────────────┘    │
              └──────────────────────────────────────┘
```

## Phase Contracts

### Planner
- **Input:** Raw intent string + active subject agent's `domain_config.json`
- **Output:** `PlannerFrame` — certified action plan with domain_actions bound to vocabulary
- **Constraint check:** Must scan `.pmcro/constraints/` before any plan is certified
- **Risk classification:** All actions classified TYPE1 (HIL-Gated) or TYPE2 (autonomous)

### Maker
- **Input:** Certified `PlannerFrame`
- **Output:** `MakerFrame` — execution record of dispatched domain_actions
- **Gate:** Will not execute without a Planner-certified frame
- **Rule:** One file output per cycle (EC-SYS-002)

### Checker
- **Input:** `MakerFrame` + original `PlannerFrame`
- **Output:** `CheckerFrame` — scored validation with mandatory conflict gates
- **Mandatory gates (pre-score):**
  - `FILE_EXISTS_CONFLICT` — output path already contains a file
  - `PATH_MISSING_CONFLICT` — target directory does not exist
- **Score threshold:** ≥ 0.85 required to pass; conflicts block scoring entirely

### Reflector
- **Input:** `CheckerFrame`
- **Output:** Terminal disposition — one of:
  - `COMPLETE` — loop ends, trail written, Orchestrator notified
  - `RETRY` — Planner re-runs with constraint context injected
  - `HALT` — hard stop; EarnedConstraint written to `.pmcro/constraints/`
- **EarnedConstraint rule:** Written immediately on hard conflicts; Planner must honor in next iteration

### Orchestrator
- **Role:** Sole routing authority — decides which subject agent handles an intent
- **MaxLoops:** Hard stop at 3 iterations by default (configurable in `config.json`)
- **MAF Triangle Gateway:** Ensures data moves correctly between MAF tiers

## Data Flow (Frame Chain)

```
Intent (string)
    │
    ▼  [Planner]
PlannerFrame
  ├── intent: string
  ├── domain_actions: DomainAction[]
  ├── risk: TYPE1 | TYPE2
  ├── constraints_checked: bool
  └── certified: bool
    │
    ▼  [Maker]
MakerFrame
  ├── planner_frame_id: guid
  ├── actions_dispatched: ActionResult[]
  ├── outputs: FileOutput[]
  └── execution_time_ms: int
    │
    ▼  [Checker]
CheckerFrame
  ├── maker_frame_id: guid
  ├── conflicts: ConflictGate[]
  ├── score: float (0.0–1.0)
  ├── passed: bool
  └── notes: string[]
    │
    ▼  [Reflector]
ReflectorVerdict
  ├── disposition: COMPLETE | RETRY | HALT
  ├── earned_constraint?: EarnedConstraint
  └── trail_path: string
```

## Loop Invariants

1. **Sequential only** — no phase skipping, no parallel execution within a cycle
2. **One file per cycle** — EC-SYS-002; multi-file intents decompose across cycles
3. **Constraint inheritance** — each RETRY cycle inherits all prior EarnedConstraints
4. **Faults are deferred** — Reflector handles faults in the next iteration, never mid-cycle
5. **Trail is always written** — even on HALT; `.pmcro/trails/` is the authoritative audit log

## MAF Workflow Graph Binding

The PMCR-O loop maps directly to `Microsoft.Agents.AI.Workflows` graph execution:

```csharp
WorkflowBuilder builder = new(plannerExecutor);
builder.AddEdge(plannerExecutor,   makerExecutor)    .WithOutputFrom(plannerExecutor);
builder.AddEdge(makerExecutor,     checkerExecutor)  .WithOutputFrom(makerExecutor);
builder.AddEdge(checkerExecutor,   reflectorExecutor).WithOutputFrom(checkerExecutor);
var pmcroWorkflow = builder.Build();

await using Run run = await InProcessExecution.RunAsync(pmcroWorkflow, intent);
```
