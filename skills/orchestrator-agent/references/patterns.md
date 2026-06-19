# patterns.md — Anthropic → PMCR-O → MAF Pattern Mapping
# Colony: {{colony_name}} · Updated: 2026-06-19
# ============================================================

## Core Mapping

| Anthropic Pattern | PMCR-O Phase | MAF Construct | When to Use |
|:------------------|:-------------|:--------------|:------------|
| Augmented LLM | Planner (single pass) | KernelFunction | Simple, one-step tasks |
| Prompt Chaining | P→M→C→R (linear) | WorkflowStep sequence | Structured, multi-step tasks |
| Evaluator–Optimizer | Reflector RETRY loop | Agent loop with state | Open-ended, iterative refinement |
| Orchestrator–Worker | Orchestrator + Subject Agent | KernelPlugin routing | Domain-specialized tasks |
| Parallelization | NOT USED in PMCR-O | N/A | PMCR-O is strictly sequential |

## Topology Selection Guide

| Intent Complexity | Topology | MAF Construct |
|:------------------|:---------|:--------------|
| Simple, deterministic | Chain-of-Thought (CoT) | Single WorkflowStep |
| Branching exploration needed | Tree-of-Thought (ToT) | Conditional WorkflowStep branches |
| Interconnected reasoning | Graph-of-Thought (GoT) | Multi-node WorkflowGraph with shared state |
| Structured business process | Workflow Graph | WorkflowDefinition + typed routing |
| Tool-heavy, open-ended | Autonomous Agent Loop | Agent-hosted loop with Evaluator–Optimizer |

## Anthropic "Building Effective Agents" Alignment

- **Simplicity first:** Use the simplest topology that satisfies the intent.
- **Explicit planning:** PlannerFrame is the explicit plan — never implicit.
- **Human control:** TYPE1 actions require HIL authorization (MAAI-001).
- **Observability:** Every phase writes a frame to `.pmcro/trails/` for full replay.
- **Failure learning:** EarnedConstraints crystallize failures into prevention rules.
