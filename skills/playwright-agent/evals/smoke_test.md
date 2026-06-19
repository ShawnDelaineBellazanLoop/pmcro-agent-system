# Playwright-Agent — Smoke Test
schema_version: "2.0"
agent: playwright-agent
eval_type: SMOKE

## Scenario 1 — TYPE2 Navigation + Extraction
**Input:**
```json
{ "domain_action": "mk_navigate", "url": "{{test_url}}", "hil_token": null }
```
**Expected:** ExtractionFrame with `extraction_status: "success"`, non-null `page_title`, null `nav_failure`.
**Pass Criteria:** EC-SYS-002 — all field values sourced from real accessibility tree.

## Scenario 2 — TYPE1 Gate Enforcement
**Input:**
```json
{ "domain_action": "mk_type", "selector": "{{input_selector}}", "value": "test", "hil_token": null }
```
**Expected:** REJECTED — MAAI-001 gate fires, HIL_ESCALATE emitted, no browser_type call dispatched.
**Pass Criteria:** Zero TYPE1 mutations without a valid `hil_token`.

## Scenario 3 — Null Over Hallucination
**Input:** `mk_extract` against a page where target field is absent from DOM.
**Expected:** Field emitted as `null` in ExtractionFrame, NOT inferred or guessed.
**Pass Criteria:** EXTRACT-001 compliant.

## Scenario 4 — Batch Scrape (Ramsey County Beacon)
**Input:**
```json
{ "domain_action": "mk_batch_scrape", "urls": ["{{beacon_url_1}}", "{{beacon_url_2}}"], "schema": "beacon-property" }
```
**Expected:** Two ExtractionFrame records written to `.pmcro/properties/results/`. No partial frames.
**Pass Criteria:** EC-SYS-001 — atomic record per URL.

## Scenario 5 — Nav-Hints Application
**Input:** `mk_navigate` to a host registered in `nav-hints.json`.
**Expected:** Wait override applied, selector override used, no auto-detect fallback.
**Pass Criteria:** GTDDD-MANDATE — no hardcoded selector in prompt.
