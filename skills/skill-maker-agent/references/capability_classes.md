# Capability Class Reference

> **Maintained by:** skill-maker-agent
> **Read this file when uncertain which `capability_class` to assign a new agent.**

A `capability_class` is the single-word (or `SNAKE_CASE`) token that names *what kind of
work* an agent does, distinct from its `tier` (PHASE/SUBJECT/SUPPORT) and its
`triangle_role` (INTERPRETATION/ORCHESTRATION/EXECUTION). Tier says *where* an agent sits
in the loop; triangle_role says *how* it behaves; capability_class says *what domain* it owns.

---

## Registered Capability Classes (Colony, current)

| Capability Class | Agent | Tier | Triangle Role |
|:------------------|:------|:-----|:---------------|
| `LOOP_CONTROLLER` | orchestrator-agent | PHASE | ORCHESTRATION |
| `STRATEGY_GENERATION` | planner-agent | PHASE | ORCHESTRATION |
| `EXECUTION_ENGINE` | maker-agent | PHASE | EXECUTION |
| `VALIDATION_GATE` | checker-agent | PHASE | EXECUTION |
| `TERMINAL_ARBITRATION` | reflector-agent | PHASE | ORCHESTRATION |
| `DOMAIN_CONFIG_PROVIDER` | filesystem-agent, git-agent | SUBJECT | EXECUTION |
| `RECURSIVE_PROVISIONER` | skill-maker-agent | SUPPORT | ORCHESTRATION |
| `DOCUMENTATION_AUTOMATION` | docfx-agent | SUBJECT | EXECUTION |

---

## Assignment Rules

1. **One class per agent.** Capability classes are not shared except by Subject Agents
   that are pure domain-config providers (e.g. `filesystem-agent` and `git-agent` both
   carry `DOMAIN_CONFIG_PROVIDER` because neither owns loop state — they only expose
   domain actions to the Maker).
2. **PHASE agents get loop-shaped classes.** If the new agent participates directly in
   Plan→Make→Check→Reflect→Orchestrate, its class should describe its loop function
   (`*_CONTROLLER`, `*_GENERATION`, `*_ENGINE`, `*_GATE`, `*_ARBITRATION`).
3. **SUBJECT agents get domain-shaped classes.** Domain experts invoked by the
   Orchestrator take a class describing the external system they automate
   (e.g. `DOCUMENTATION_AUTOMATION`, `DOMAIN_CONFIG_PROVIDER`).
4. **SUPPORT agents get infrastructure-shaped classes.** Colony-maintenance agents that
   are not part of the live loop (e.g. `skill-maker-agent`) take a class describing the
   meta-capability they provide (`RECURSIVE_PROVISIONER`).
5. **Never reuse `LOOP_CONTROLLER`, `STRATEGY_GENERATION`, `EXECUTION_ENGINE`,
   `VALIDATION_GATE`, or `TERMINAL_ARBITRATION`.** These five are reserved for the
   five canonical PMCR-O phase agents and must not be assigned to any new agent.
6. **New class naming:** `SCREAMING_SNAKE_CASE`, 1-3 words, noun-phrase describing the
   capability not the implementation (`DOCUMENTATION_AUTOMATION`, not `DOCFX_WRAPPER`).

---

## Worked Example

> Intent: "Provision an agent that automates Slack notifications for trail dispositions."

- Tier → `SUBJECT` (domain expert invoked by Orchestrator, not part of the core loop)
- Triangle role → `EXECUTION` (it mutates state — sends messages)
- Capability class → `NOTIFICATION_DISPATCH` (new class; doesn't collide with the
  reserved five or with `DOMAIN_CONFIG_PROVIDER` / `DOCUMENTATION_AUTOMATION`)

Add the new row to the table above and to `S:\registry.yaml` once the package is sealed.
