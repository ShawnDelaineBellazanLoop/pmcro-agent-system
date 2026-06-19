---
title: Getting Started
description: Prerequisites, repository layout, and first-run instructions for the Tooensure Colony PMCR-O Agent System.
uid: articles.getting-started
---

# Getting Started

## Prerequisites

| Requirement | Version | Notes |
|:------------|:--------|:------|
| .NET SDK | **10.0** (LTS) | `dotnet --version` — LTS released Nov 2025 |
| Visual Studio | **2026 18.x** | Required for full .NET 10 / C# 14 tooling |
| Microsoft Agent Framework | 1.7.0 | `Microsoft.Agents.AI` NuGet |
| DocFX | **2.78.5** | Pinned in `.config/dotnet-tools.json`; `dotnet tool restore` |
| Ollama | latest | Local LLM inference host |
| Model | `qwen3:8b` | `ollama pull qwen3:8b` |
| OllamaSharp | 5.4.25 | NuGet package |
| .NET Aspire | 13.4.3 | AppHost orchestration |
| Patchright | 1.59.0 | Browser automation (optional) |
| ReFS DevDrive | S:\ | Recommended for I/O performance |

> [!NOTE]
> DocFX 2.78.5 targets `.NET 8.0+` and runs on the .NET 10 runtime without changes.
> Node.js is **not** required for tool users — it was removed as a runtime dependency in 2.78.x.

## Repository Layout

```
S:\
├── registry.yaml                  # Master skill registry
├── .pmcro\                        # Runtime directory
│   ├── identity.json              # Colony identity (token source)
│   ├── config.json                # Runtime config
│   ├── laws\                      # Colony law declarations
│   ├── skills\runtime-manifest.json
│   ├── trails\                    # Execution audit trails
│   ├── constraints\               # EarnedConstraints
│   └── generated\                 # Maker outputs staging
├── skills\                        # Agent skill packages
│   ├── orchestrator-agent\
│   ├── planner-agent\
│   ├── maker-agent\
│   ├── checker-agent\
│   ├── reflector-agent\
│   ├── filesystem-agent\
│   ├── git-agent\
│   ├── skill-maker-agent\
│   └── docfx-agent\
└── docs\                          # This DocFX site
    ├── docfx.json
    ├── toc.yml
    ├── index.md
    ├── articles\
    ├── agents\
    ├── media\
    └── my-template\
```

## First Run

### 1. Restore .NET tools and packages

```powershell
# Restore pinned DocFX local tool (2.78.5)
cd S:\docs
dotnet tool restore

# Restore project packages
cd S:\src
dotnet restore
```

### 2. Start Ollama

```powershell
ollama serve
# In a second terminal:
ollama run qwen3:8b
```

### 3. Start the Aspire AppHost

```powershell
cd S:\src\AppHost
dotnet run
```

The Aspire dashboard opens at `https://localhost:15888`. The agent service is available at `https://localhost:5001`.

### 4. Send an intent

```http
POST https://localhost:5001/agent/intent
Content-Type: application/json

{
  "intent": "Create a new git-agent skill package under S:\\skills\\",
  "subject": "skill-maker-agent"
}
```

The PMCR-O loop executes: Orchestrator → Planner → Maker → Checker → Reflector → trail written to `.pmcro/trails/`.

## Invoking a Specific Agent

Prefix your message with the agent name to route directly:

```
/orchestrator-agent   <intent>
/skill-maker-agent    <provisioning request>
/docfx-agent          <documentation request>
/filesystem-agent     <file operation>
/git-agent            <git operation>
```

## Build the DocFX Site

```powershell
cd S:\docs
.\scripts\build.ps1 -WarningsAsErrors -Serve
# Output: S:\docs\_site\index.html
# Dev server: http://localhost:8080
```

## Validate Documentation

```powershell
cd S:\docs
.\scripts\validate.ps1
# Runs: link-check, xref-check, warningsAsErrors dry-run, JSON schema lint
```

## Troubleshooting

| Symptom | Cause | Fix |
|:--------|:------|:----|
| `docfx: command not found` | Tool not restored | Run `dotnet tool restore` in `S:\docs` |
| `{{token}}` renders in output | Unresolved GTDDD-MANDATE token | Check `docfx.json` globalMetadata and all `.md` front matter |
| Search returns no results | `ExtractSearchIndex` not in `postProcessors` | Confirm `docfx.json` `postProcessors: ["ExtractSearchIndex"]` |
| Empty folder missing from zip | `archive_util.py` pre-fix version | Run `batch_package.py` — fixed version writes explicit directory entries |
| QEMU segfault in Docker | .NET SDK not supported on QEMU emulation | Use native arm64 runner or x64 host, not emulated cross-arch |
