# DevOps-Agent — MCP Health Endpoints Reference
schema_version: "2.0"
agent: devops-agent

## Registered MCP Servers

| Server | Port Token | Health URL | Dependency |
|:-------|:-----------|:-----------|:-----------|
| playwright-mcp | `{{playwright_mcp_port}}` | `http://localhost:{{playwright_mcp_port}}/health` | playwright-agent workflows |
| filesystem-mcp | `{{filesystem_mcp_port}}` | `http://localhost:{{filesystem_mcp_port}}/health` | filesystem-agent workflows |
| terminal-mcp   | `{{terminal_mcp_port}}`   | `http://localhost:{{terminal_mcp_port}}/health`   | devops-agent self |

## Health Check Protocol
1. Call `mk_mcp_health` for each server the current workflow requires.
2. If any server returns non-200 or times out: emit `earned_constraint_trigger` and HIL_ESCALATE.
3. Never proceed with a workflow if its MCP dependency is unreachable.

## Validation Script
Run `scripts/validate-all-mcp.ps1` to check all three servers simultaneously.
