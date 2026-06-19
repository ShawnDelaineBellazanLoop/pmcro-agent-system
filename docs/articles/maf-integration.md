---
title: MAF 1.7.0 Integration
uid: articles.maf-integration
---

# MAF 1.7.0 Integration

> **Validated:** 2026-06-19 | Source: `S:\skills\skill-maker-agent\references\maf_versions.md`

Microsoft Agent Framework (MAF) 1.0 GA shipped April 3, 2026. It is the unified successor to Semantic Kernel and AutoGen. The Colony's `MAF` naming convention was already correct.

---

## Package Reference

```xml
<ItemGroup>
  <!-- MAF Core — always include -->
  <PackageReference Include="Microsoft.Agents.AI"           Version="1.7.0" />
  <PackageReference Include="Microsoft.Agents.AI.Hosting"   Version="1.7.0" />
  <PackageReference Include="Microsoft.Agents.AI.Workflows"  Version="1.7.0" />

  <!-- Local LLM via Ollama -->
  <PackageReference Include="OllamaSharp"                   Version="5.4.25" />

  <!-- Optional: A2A protocol hosting (preview) -->
  <PackageReference Include="Microsoft.Agents.AI.Hosting.A2A" Version="1.8.0-preview.260528.1" />

  <!-- Optional: Dev debugging UI -->
  <PackageReference Include="Microsoft.Agents.AI.DevUI"     Version="1.7.0" />

  <!-- Aspire AppHost orchestration -->
  <PackageReference Include="Aspire.Hosting"                Version="13.4.3" />
</ItemGroup>
```

---

## MAF Architecture Inside the Colony

```
┌─────────────────────────────────────────────────────────────────┐
│                    Microsoft Agent Framework 1.7.0               │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Semantic Kernel Foundation Layer            │   │
│  │  KernelFunction · KernelPlugin · IChatCompletionService │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                   │
│  ┌───────────────────────────▼───────────────────────────────┐  │
│  │              Graph Workflows (AutoGen successor)           │  │
│  │  WorkflowBuilder · BindAsExecutor · AddEdge               │  │
│  └───────────────────────────┬───────────────────────────────┘  │
│                              │                                   │
│  ┌───────────────────────────▼───────────────────────────────┐  │
│  │                     Protocols Layer                        │  │
│  │   MCP (tools)  ·  A2A (agents)  ·  AG-UI (users)         │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
              Colony PMCR-O Loop binds here
```

---

## KernelFunction Contract (Colony Standard)

All Colony PHASE agents implement the `[KernelFunction]` attribute:

```csharp
using Microsoft.SemanticKernel;  // SK is the foundation layer — still valid

[KernelFunction("RouteIntent")]
[Description("Routes intent through PMCR-O phases. Returns OrchestratorFrame JSON.")]
public Task<OrchestratorFrame> RouteIntentAsync(string request);
```

Frame types per agent:

| Agent | KernelFunction | Return Type |
|:------|:--------------|:------------|
| orchestrator-agent | `RouteIntent` | `OrchestratorFrame` |
| planner-agent | `DecomposeIntent` | `PlannerFrame` |
| maker-agent | `ExecutePlan` | `MakerFrame` |
| checker-agent | `ValidateOutput` | `CheckerFrame` |
| reflector-agent | `IssueVerdict` | `ReflectorVerdict` |

---

## MCP Integration

MCP (Model Context Protocol) connects agents to tools and data sources. It is built into `Microsoft.Agents.AI` core — no extra package required.

**Colony pattern:** SUBJECT agents (`filesystem-agent`, `git-agent`) expose their `domain_scripts` as MCP tool endpoints. PHASE agents discover and invoke them at runtime.

```csharp
// Register MCP server in Aspire AppHost
builder.AddMcpServer("filesystem-mcp")
       .WithHttpTransport()
       .WithToolsFromAssembly<FilesystemAgentPlugin>();
```

**ngrok tunnel:** The `agentservice` endpoint is tunneled via ngrok for external access:
```
https://speak-flint-geiger.ngrok-free.app → https://localhost:5001
```

---

## A2A Integration (Preview)

A2A (Agent-to-Agent Protocol) connects agents to other agents across runtimes. Uses `Microsoft.Agents.AI.Hosting.A2A` 1.8.0-preview.

**Colony use:** Future cross-Colony communication. Each agent publishes an Agent Card (JSON) advertising capabilities + endpoints.

> **MCP ≠ A2A.** MCP = tools. A2A = agents. Do not substitute one for the other.

---

## Ollama / Local LLM

The Colony runs `qwen3:8b` locally via Ollama and OllamaSharp 5.4.25:

```csharp
using OllamaSharp;

var ollama = new OllamaApiClient(new Uri("http://localhost:11434"));
var chatService = new OllamaChatCompletionService("qwen3:8b", ollama);

kernel.AddChatCompletionService(chatService);
```

---

## Orchestration Patterns

| MAF Pattern | Colony Usage |
|:------------|:------------|
| **Sequential** | Default — PMCR-O single-subject loop (EC-SYS-002) |
| **Handoff** | Orchestrator dynamic routing between subject agents |
| **Concurrent** | Not used — violates EC-SYS-002 |
| **Group Chat** | Not used — single authority per cycle |
| **Magentic-One** | Reserved for future full-reasoning orchestration mode |
