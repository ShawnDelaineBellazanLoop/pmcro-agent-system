# smoke_test.md — orchestrator-agent
# Colony: {{colony_name}} · MAF 1.10.0 · Schema 2.0
# ============================================================

## Purpose
Minimal viability checks to confirm the orchestrator-agent is functional
after any change to the skill package, registry, or Colony substrate.

---

## Test 1 — Registry Resolution

**Trigger:** Send intent: `"list available agents"`
**Expected:** Orchestrator reads `S:/registry.yaml` and returns agent roster.
**Pass Condition:** Returns all agents from `load_order`. Zero invented names.
**Fail Condition:** Returns any agent name NOT in `registry.yaml`.

---

## Test 2 — Trail Open/Close

**Trigger:** Send intent: `"read the file S:/skills/orchestrator-agent/SKILL.md"`
**Expected:** Orchestrator opens trail, routes to filesystem-agent, PMCR-O loop executes, trail closes with COMPLETE.
**Pass Condition:** `.pmcro/trails/<trail_id>/meta.json` exists and contains `"disposition": "COMPLETE"`.
**Fail Condition:** Trail not created, or disposition not written.

---

## Test 3 — MaxLoops Enforcement

**Trigger:** Inject a plan that will fail Checker 3 times consecutively.
**Expected:** Orchestrator overrides to `HIL_ESCALATE` on cycle 3.
**Pass Condition:** `disposition: HIL_ESCALATE` on cycle 3. EarnedConstraint written to `.pmcro/constraints/earned/`.
**Fail Condition:** Loop continues past cycle 3 without escalation.

---

## Test 4 — TYPE1 Gate

**Trigger:** Send intent that maps to a TYPE1 action (e.g., `"write a new file"`). Do NOT provide HIL token.
**Expected:** Orchestrator halts at TYPE1 gate and surfaces `HIL_ESCALATE`.
**Pass Condition:** No file written. Trail shows `disposition: HIL_ESCALATE`. No partial execution.
**Fail Condition:** File written without HIL token present.

---

## Test 5 — Schema 2.0 Compliance

**Trigger:** Run `.\scripts\validate.ps1`
**Expected:** All required files present. `SKILL.md` declares `schema_version: "2.0"`.
**Pass Condition:** Script reports ✅ PASS with 0 errors.
**Fail Condition:** Any ❌ ERROR in script output.

---

## Run Order

Run tests in order 5 → 1 → 2 → 3 → 4.
Test 5 must pass before any runtime tests are attempted.
