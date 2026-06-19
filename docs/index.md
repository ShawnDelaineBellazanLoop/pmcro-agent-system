---
title: "Tooensure Colony — PMCR-O Agent System"
uid: home
---

# Tooensure Colony — PMCR-O Agent System

**Version:** 4.6.0 · **MAF:** 1.7.0 · **Stack:** .NET 9 / MCP / A2A · **Owner:** Tooensure LLC

The Colony is a multi-agent cognitive loop framework built on the Microsoft Agent Framework (MAF) 1.7.0. It implements the **PMCR-O loop** — Planner → Maker → Checker → Reflector → Orchestrator — as a strictly sequential, law-governed agent system running on a ReFS DevDrive (S:\).

---

## Architecture at a Glance

```
Human Intent
     │
     ▼
┌─────────────────────────────────────────────────────┐
│                 ORCHESTRATOR-AGENT                   │
│           (Loop Controller · ORCHESTRATION)          │
└────────────────────┬────────────────────────────────┘
                     │ routes to subject agent
     ┌───────────────▼──────────────────┐
     │          PHASE AGENTS            │
     │                                  │
     │  PLANNER ──► MAKER ──► CHECKER  │
     │                │                 │
     │           REFLECTOR ◄────────── │
     └───────────────┬──────────────────┘
                     │ invokes domain_config
     ┌───────────────▼──────────────────┐
     │         SUBJECT AGENTS           │
     │  filesystem · git · docfx        │
     └──────────────────────────────────┘
```

---

## Colony Laws

All agents honor three inviolable laws:

| Law | Rule |
|:----|:-----|
| **EC-SYS-001** | Every file output must be complete — no fragments, no stubs |
| **EC-SYS-002** | One file per PMCR-O cycle — minimalist planning only |
| **GTDDD-MANDATE** | All generated files use `{{token}}` placeholders — never hardcoded identity |

---

## Quick Links

- [Getting Started](articles/getting-started.md)
- [PMCR-O Architecture](articles/architecture.md)
- [Colony Laws](articles/colony-laws.md)
- [Agent Types & Tiers](articles/agent-types.md)
- [MAF 1.7.0 Integration](articles/maf-integration.md)
- [Orchestrator Agent](agents/orchestrator-agent.md)
- [Skill Registry](articles/registry.md)
