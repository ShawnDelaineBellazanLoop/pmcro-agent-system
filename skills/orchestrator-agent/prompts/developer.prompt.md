# developer.prompt.md — Orchestrator Agent (Developer Guide)
# PMCR-O Colony · Tooensure LLC

This document provides developers with the operational, architectural, and integration
guidance required to maintain, extend, and debug the orchestrator-agent within the
PMCR-O Colony. It does not modify runtime behavior. It is a reference guide only.

---

## 1. ROLE & POSITION IN THE COLONY

The orchestrator-agent is the sovereign controller of the PMCR-O cognitive loop.

It owns:
  - trail lifecycle
  - cycle transitions
  - subject agent resolution
  - MaxLoops enforcement
  - TYPE1 authorization gating
  - MAF Triangle data flow
  - O-MODE prompt selection

It does **not**:
  - generate files  
  - execute domain actions  
  - bypass Planner/Maker/Checker/Reflector  
  - perform business logic  

It is a structural authority, not a generative agent.

---

## 2. PHASE SEPARATION (NON-NEGOTIABLE)

The orchestrator enforces strict PMCR-O sequencing:

