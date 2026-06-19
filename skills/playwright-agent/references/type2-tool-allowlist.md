# Playwright Agent — TYPE2 Tool Allowlist
# Schema: 2.0 | Colony: {{colony_name}}
# Source of truth for read-only browser operations. Planner must reference this before generating steps.

## TYPE2 Tools (execute without HIL token)

| Tool | MCP Method | Description | Output |
|:-----|:-----------|:------------|:-------|
| `browser_navigate` | `browser_navigate` | Navigate to a URL and wait for page load | Page URL confirmation |
| `browser_snapshot` | `browser_snapshot` | Capture full accessibility tree of current page | Structured tree JSON |
| `browser_screenshot` | `browser_screenshot` | Capture visual PNG to `{{screenshot_dir}}` | File path |
| `browser_evaluate` | `browser_evaluate` | Execute read-only JS expression (no DOM mutation) | Expression result |
| `browser_wait` | `browser_wait` | Wait N milliseconds before next action | Elapsed ms |
| `browser_get_url` | `browser_evaluate` | Return `window.location.href` | URL string |
| `browser_get_title` | `browser_evaluate` | Return `document.title` | String |

## TYPE1 Tools (require MAAI-001 HIL token)

| Tool | MCP Method | Risk | Notes |
|:-----|:-----------|:-----|:------|
| `browser_click` (submit) | `browser_click` | MEDIUM | Only when clicking form submit, checkout, or confirm buttons |
| `browser_type` | `browser_type` | HIGH | Any text input — credentials, PII, form data |
| `browser_form_post` | `browser_click` + `browser_type` | HIGH | Full form completion + submission |

## Boundary Rule

The Playwright-Agent NEVER executes TYPE1 tools without a HIL token present in the current
cycle context. If a Planner step requires a TYPE1 tool and no HIL token is available,
the agent emits `{ "hil_required": true }` and halts. The Orchestrator then gates on MAAI-001.

## Never Use

- Direct Playwright Node.js/Python API calls (violates ARCH-003)
- `browser_evaluate` with DOM-mutating JS (`document.write`, `fetch POST`, etc.)
- Any MCP tool not on this allowlist without explicit Orchestrator approval
