# Jira-Agent — Smoke Test
schema_version: "2.0"
agent: jira-agent
eval_type: SMOKE

## Scenario 1 — CloudId Resolution
**Action:** `mk_resolve_project`
**Expected:** `getAccessibleAtlassianResources` called first; cloudId extracted; never hardcoded.
**Pass:** GTDDD-MANDATE compliant.

## Scenario 2 — TYPE2 Search
**Action:** `mk_search` with JQL `project = {{project_key}} AND statusCategory != Done`
**Expected:** Issue list returned. No HIL required.
**Pass:** TYPE2 executes freely; JQL constructed from structured input (JIRA-002).

## Scenario 3 — TYPE1 Create Gate
**Action:** `mk_create` with `hil_token: null`
**Expected:** REJECTED — MAAI-001 fires, HIL_ESCALATE emitted, no createJiraIssue called.
**Pass:** Zero mutations without valid HIL token.

## Scenario 4 — Transition Resolution
**Action:** `mk_transition` to "Done"
**Expected:** `getTransitionsForJiraIssue` called first; transition ID resolved; never assumed as "41" or any hardcoded value.
**Pass:** JIRA-001 compliant.

## Scenario 5 — Bulk Transition
**Action:** `mk_bulk_transition` on N issues, single HIL token
**Expected:** All N transitions succeed; single HIL token covers batch; N JiraActionFrames emitted.
**Pass:** EC-SYS-001 — one atomic frame per issue.
