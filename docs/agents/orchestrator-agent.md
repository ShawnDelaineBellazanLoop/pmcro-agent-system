---
title: Orchestrator Agent
uid: agents.orchestrator-agent
---

# orchestrator-agent

**Type:** PHASE · **Tier:** ORCHESTRATION · **Capability:** LOOP_CONTROLLER  
**KernelPlugin:** `PmcroOrchestrator` · **KernelFunction:** `RouteIntent`

Central authority for trail lifecycle, cycle transitions, and subject agent resolution. The Orchestrator is not merely a router — it **owns every trail** from open to close. Each high-level goal maps to one trail; each cycle within that trail is an Orchestrator-governed transition.

---

## Trail Ownership

```
Orchestrator opens trail (intent received)
    │
    ├── Cycle 1 ──► P ──► M ──► C ──► R ──► ReflectorVerdict
    │                                            │
    │                              Orchestrator receives verdict
    │                                            │
    │                    ┌───────────────────────┤
    │                    │                       │
    │               COMPLETE                   RETRY
    │          Orchestrator closes          Orchestrator checks
    │          trail (success)              cycle_count < max_cycles
    │                                            │
    │                                    ┌───────┴────────┐
    │                                    │                │
    │                             within limit        at limit
    │                           advance Cycle 2    override → HALT
    │                                    │                │
    ├── Cycle 2 ──► P ──► M ──► C ──► R │           Orchestrator
    │                                    │           closes trail
    └── ...                              │           (failed)
```

**The Reflector issues a disposition recommendation. The Orchestrator acts on it.**  
MaxLoops is an Orchestrator invariant enforced at the cycle transition boundary — the Reflector has no knowledge of the cycle counter.

---

## Responsibilities

- **Trail lifecycle owner** — opens trail on intent receipt; closes trail on COMPLETE or HALT; every cycle is an Orchestrator-governed transition
- **Cycle transition authority** — receives `ReflectorVerdict`; decides ADVANCE (RETRY → next cycle) or CLOSE (COMPLETE/HALT)
- **MaxLoops enforcer** — checks `cycle_count >= max_cycles` at every transition boundary; overrides to HALT if limit reached regardless of Reflector verdict
- **Subject agent resolver** — activates exactly one subject agent per cycle via registry lookup
- **TYPE1 dispatcher** — validates MAAI-001 tokens for state-mutating actions before dispatching
- **MAF Triangle Gateway** — enforces ORCHESTRATION → EXECUTION → ORCHESTRATION data flow

---

## MAF Contract

```csharp
[KernelFunction("RouteIntent")]
[Description("Opens a trail, governs cycle transitions, closes trail on terminal disposition.")]
public Task<OrchestratorFrame> RouteIntentAsync(string request);
```

---

## OrchestratorFrame Schema

```json
{
  "trail_id": "uuid",
  "intent": "string",
  "subject_agent": "agent-name",
  "cycle_count": 1,
  "max_cycles": 3,
  "cycle_disposition": "COMPLETE | RETRY | HALT",
  "trail_status": "OPEN | CLOSED",
  "timestamp": "ISO8601"
}
```

---

## Invocation

```
/orchestrator-agent <intent>
```

```http
POST https://localhost:5001/agent/intent
Content-Type: application/json

{ "intent": "your intent here" }
```

---

## Loop Authorities

| Authority | Rule |
|:----------|:-----|
| **Trail Owner** | Opens trail on receipt; closes on COMPLETE or HALT; trail is the Orchestrator's audit log |
| **Cycle Transition** | Sole decider of ADVANCE vs CLOSE after each ReflectorVerdict |
| **MaxLoops Enforcer** | Checks counter at transition boundary; overrides Reflector if limit reached |
| **Subject Agent Resolver** | Only the Orchestrator activates a subject agent per cycle |
| **TYPE1 Dispatcher** | No state-mutating action without MAAI-001 token |
| **MAF Triangle Gateway** | Enforces correct data flow between tiers |

---

## SKILL.md Location

`S:\skills\orchestrator-agent\SKILL.md`
