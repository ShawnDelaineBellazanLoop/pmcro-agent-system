# Git Agent — Dynamic Domain Architecture
**Version:** 4.6.3
**Domain:** version-control-operations

This reference governs the high-speed interaction between the PMCR-O loop and 
repositories hosted on the ReFS Dev Drive.

---

## 🏗️ Dynamic Operational Structure
The `git-agent` now operates as a **Dynamic Utility Provider**. It no longer 
assumes the location of the repository. The loop must provide the `--repo` 
path for every operation.

### The 'git_op' Protocol
All complex workflows are consolidated into `scripts/git_util.py`. This script 
is the functional specification for the future **PMCRO-Git-MCP** server.

**Standard Actions:**
- `status`: Provides a short-form view of uncommitted changes.
- `log`: Displays the most recent 5 commits for context synchronization.
- `sync`: An atomic chain: `add .` -> `commit` -> `pull --rebase` -> `push`.

---

## 📜 Repository Health Requirements
Before the `git-agent` can execute a `git_op`, the target directory must be 
a valid Git repository (containing a `.git` folder). 

### Initialization Protocol:
If a repository is missing, the Orchestrator must escalate to HIL to run:
`git init && git add . && git commit -m "Initial Commit"`

---

## ⚖️ System Law Enforcement

### EC-SYS-001: Atomic Commit Protocol
The `sync` action in `git_util.py` is the primary enforcer of atomicity. It 
ensures that the remote origin and the local `S:` drive are in perfect 
alignment. If the `pull --rebase` fails due to conflicts, the script 
**aborts** to prevent the Maker from corrupting the history.

### Security: No-Force Policy
To protect the "Gold Baseline," the `git_util.py` script intentionally 
omits support for `--force` or `reset --hard`. These are terminal 
actions requiring human physical presence (MAAI-001).

---

## 🚦 Risk Classification Rationale
- **TYPE1 (High Risk):** `git_op --action sync`. This alters the remote 
  shared history.
- **TYPE2 (Low Risk):** `git_op --action status`, `git_op --action log`. 
  These are non-mutating inspection tools.