# versions.md — Orchestrator Agent
# Colony: {{colony_name}} · Updated: 2026-06-19
# ============================================================

## Pinned Versions

| Package | Version | Source |
|:--------|:--------|:-------|
| Microsoft Agent Framework (MAF) | 1.10.0 | https://github.com/microsoft/agentframework |
| Microsoft.Extensions.AI | 10.7.0 | NuGet |
| Microsoft.Extensions.AI.OpenAI | 10.7.0 | NuGet |
| Serilog.AspNetCore | 8.0.0 | NuGet |
| OpenTelemetry.Extensions.Hosting | 1.9.0 | NuGet |
| OpenTelemetry.Exporter.Console | 1.9.0 | NuGet |
| .NET SDK | net9.0 | https://dotnet.microsoft.com |
| PMCR-O Colony Schema | 2.0 | Internal |
| PMCR-O Skill Version | 5.0.0 | Internal |

## Validated Compatibility Matrix

| MAF | AI SDK | .NET | Status |
|:----|:-------|:-----|:-------|
| 1.10.0 | 10.7.0 | net9.0 | ✅ VALIDATED |
| 1.7.0 | 10.0.0 | net8.0 | ⚠️ LEGACY — do not use for new work |

## Notes
- Do NOT upgrade any package version without running evals/smoke_test.md first.
- Any version change requires a registry.yaml update and a new git commit with trail_id.
