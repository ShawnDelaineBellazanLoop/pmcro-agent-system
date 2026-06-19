---
name: docfx-agent
description: Orchestrates multi-agent workflow for DocFX documentation projects using PMCR-O loop. Integrates filesystem-agent and git-agent for reliable artifact management.
---

# DocFX Agent Skill

## Overview
This skill implements a robust **PMCR-O** (Planner → Maker → Checker → Reflector → Orchestrator) loop tailored for DocFX documentation generation.

## Core Workflow (Orchestrator-Driven)

1. **Orchestrator-Agent** (Coordinator):
   - Parse high-level goal.
   - Inventory resources using **filesystem-agent**.
   - Load required skills: `filesystem-agent`, `git-agent`.
   - Define success criteria and start cycle.
   - Delegate to Planner.

2. **Planner-Agent**:
   - Creates **bare-minimum viable plan** based on validated artifacts.
   - Specifies exact files, commands, and metrics.

3. **Maker-Agent**:
   - Loads `filesystem-agent` and `git-agent` patterns.
   - Executes plan: create/edit artifacts using `write_file`, `edit_file`, `bash` (docfx commands).
   - Uses git-agent for initial commit if needed.

4. **Checker-Agent**:
   - Validates artifacts with `filesystem-agent` (read/inspect files, run `docfx build`).
   - Checks build success, structure, links.
   - Reports precise issues.

5. **Reflector-Agent**:
   - Analyzes cycle.
   - Crystallizes learnings into training data.
   - Feeds back to Orchestrator.

6. **Loop**: Repeat until Checker approves or max iterations reached. Use `git-agent` to commit successful states.

## Explicit Integration with filesystem-agent and git-agent

- **filesystem-agent**: Used by Maker and Checker for all file/directory operations as **artifacts**.
- **git-agent**: Used after every successful Checker pass to version the state of the documentation project.

## When to Use
Any DocFX-related task: init, build, API docs, Markdown content, site customization.

## Setup
Use `bash` for `docfx` CLI commands. Always treat generated files as artifacts.