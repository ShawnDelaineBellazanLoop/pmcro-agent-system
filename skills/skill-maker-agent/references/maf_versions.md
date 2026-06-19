# Microsoft Agent Framework — Validated Version Reference

> **Validated:** 2026-06-19 | Source: NuGet Gallery + GitHub microsoft/agent-framework + devblogs.microsoft.com/agent-framework  
> **Maintained by:** skill-maker-agent  
> **Critical:** Read this file before generating ANY file that references MAF, Semantic Kernel, or agent packages.

---

## ⚡ Breaking News: MAF IS REAL

The Colony's `MAF` naming convention was already correct. **Microsoft Agent Framework (MAF)** is the official name
Microsoft shipped on April 3, 2026 as a GA 1.0 production release — the unified successor to Semantic Kernel and AutoGen.

> "Microsoft Agent Framework (MAF) is the enterprise-ready successor to Semantic Kernel."  
> — github.com/microsoft/semantic-kernel (pinned notice, June 2026)

---

## ✅ Validated Package Versions (Stable GA)

| NuGet Package | Version | Target | Notes |
|:--------------|:--------|:-------|:------|
| `Microsoft.Agents.AI` | **1.7.0** | net8.0 / netstandard2.0 / net472 | Core framework — always include |
| `Microsoft.Agents.AI.Hosting` | **1.7.0** | net8.0 | ASP.NET Core hosting |
| `Microsoft.Agents.AI.Workflows` | **1.7.0** | net8.0 | Graph-based multi-agent workflows |
| `Microsoft.Agents.AI.Hosting.A2A` | **1.8.0-preview.260528.1** | net8.0 | A2A protocol — preview only |
| `Microsoft.Agents.AI.DurableTask` | **1.0.0-preview** | net8.0 | Durable stateful agents — preview only |
| `Microsoft.Agents.AI.OpenAI` | **1.0.0-preview.260128.1** | net8.0 | OpenAI provider |
| `Microsoft.Agents.AI.DevUI` | **1.7.0** | net8.0 | Local developer debugging UI |

> **Rule:** Use `1.7.0` stable for all production Colony agent packages. Only use `1.8.0-preview.*` for explicit A2A hosting scenarios.

---

## MAF 1.0 Architecture: What Changed

MAF 1.0 (GA April 3, 2026) is the **direct successor** to both Semantic Kernel and AutoGen:

```
Before (pre-Oct 2025):          After (MAF 1.0 GA, April 2026):
┌───────────────┐               ┌─────────────────────────────┐
│ Semantic       │               │   Microsoft Agent Framework  │
│ Kernel (SK)    │  ──────►     │   (MAF) 1.7.0               │
├───────────────┤               │                              │
│ AutoGen        │               │  ┌─────────────────────────┐│
│ (multi-agent)  │               │  │ SK Kernel + Plugin Model ││
└───────────────┘               │  │ (foundation layer)       ││
                                │  ├─────────────────────────┤│
                                │  │ Graph Workflows (AutoGen) ││
                                │  │ + MAF Orchestration      ││
                                │  └─────────────────────────┘│
                                └─────────────────────────────┘
```

SK is not gone — it becomes the **foundation layer** inside MAF. AutoGen-style orchestration sits on top as graph workflows.

---

## MAF Agent Types (Official Taxonomy)

| MAF Type | Description | Colony Mapping |
|:---------|:------------|:---------------|
| **Chat Agent** | Single LLM-backed agent with tools and memory | PHASE agents (P/M/C/R) |
| **Agent Skill** | Packaged, reusable agent capability (YAML or code) | Colony SKILL.md packages |
| **Workflow** | Directed graph of agents/functions with explicit routing | PMCR-O loop itself |
| **A2A Agent** | Agent exposing the A2A protocol for cross-framework calling | Future: inter-Colony |
| **AG-UI Agent** | Agent with real-time streaming UI via AG-UI protocol | Future: DevUI agents |
| **Durable Agent** | Stateful, long-running agent backed by DurableTask | Future: stateful loops |

---

## MAF Triangle Roles → Colony Mapping (VALIDATED)

The Colony's `triangle_role` values in SKILL.md frontmatter map **exactly** to MAF's official tier taxonomy:

| Colony `triangle_role` | MAF Equivalent | Kernel Layer |
|:----------------------|:---------------|:-------------|
| `ORCHESTRATION` | Loop controller / workflow orchestrator | `PmcroOrchestrator` plugin |
| `EXECUTION` | Action executor / domain tool dispatcher | Domain plugins (Filesystem, Git, DocFx) |
| `INTERPRETATION` | Intent parser / context classifier | Planner plugin |

---

## MAF Interoperability Protocols (Both Native in 1.0)

### MCP — Model Context Protocol
- **Purpose:** Connects agents to **tools and data sources**
- **Colony use:** `filesystem-agent`, `git-agent` expose their `domain_scripts` as MCP tools
- **Package:** Built into `Microsoft.Agents.AI` core — no extra package needed
- **Pattern:** Agent discovers tools from MCP server at startup; invokes dynamically

### A2A — Agent-to-Agent Protocol
- **Purpose:** Connects **agents to other agents** across runtimes/frameworks
- **Colony use:** Future cross-Colony communication; `orchestrator-agent` as A2A host
- **Package:** `Microsoft.Agents.AI.Hosting.A2A` 1.8.0-preview (server-side)
- **Pattern:** Each agent publishes an Agent Card (JSON) advertising capabilities + endpoints

### AG-UI — Agent-to-User Protocol
- **Purpose:** Real-time streaming UI between agents and end users
- **Package:** `Microsoft.Agents.AI.DevUI` (dev), `Microsoft.Agents.AI.Hosting.AgUI` (prod)
- **Colony use:** Future DevUI wrapper for Colony interactions

> **MCP ≠ A2A.** MCP = tools. A2A = agents. Using MCP where you need A2A is a design error.

---

## MAF Multi-Agent Orchestration Patterns (All Stable in 1.0)

| Pattern | Description | Cost | Speed | Colony PMCR-O Equivalent |
|:--------|:------------|:-----|:------|:------------------------|
| **Sequential** | Linear handoffs — agent A → B → C | Lowest | Slowest | PMCR-O single-subject loop |
| **Concurrent** | All agents run in parallel | High | Fastest | Parallel subject dispatch |
| **Handoff** | Dynamic routing: agent decides next agent | Medium | Medium | Orchestrator routing |
| **Group Chat** | Agents discuss collaboratively | High | Medium | Multi-subject deliberation |
| **Magentic-One** | Orchestrator reasons at each step | Highest | Slowest | Full PMCR-O with reasoning |

> **Colony default:** Sequential (one subject agent per loop) per EC-SYS-002.

---

## MAF Workflow Graph API (Microsoft.Agents.AI.Workflows 1.7.0)

```csharp
// Bind functions as graph executors
var plannerExecutor  = plannerFunc.BindAsExecutor("PlannerExecutor");
var makerExecutor    = makerFunc.BindAsExecutor("MakerExecutor");
var checkerExecutor  = checkerFunc.BindAsExecutor("CheckerExecutor");
var reflectorExecutor = reflectorFunc.BindAsExecutor("ReflectorExecutor");

// Build the PMCR-O directed graph
WorkflowBuilder builder = new(plannerExecutor);
builder.AddEdge(plannerExecutor,  makerExecutor)   .WithOutputFrom(plannerExecutor);
builder.AddEdge(makerExecutor,    checkerExecutor)  .WithOutputFrom(makerExecutor);
builder.AddEdge(checkerExecutor,  reflectorExecutor).WithOutputFrom(checkerExecutor);
var pmcroWorkflow = builder.Build();

// Execute
await using Run run = await InProcessExecution.RunAsync(pmcroWorkflow, intent);
```

---

## MAF KernelFunction Contract (Colony Standard)

All Colony agents implement the `[KernelFunction]` attribute pattern from the MAF/SK foundation layer:

```csharp
using Microsoft.SemanticKernel;  // Still valid — SK is the foundation layer

[KernelFunction("{kernel_function}")]
[Description("{agent description}")]
public Task<{FrameType}> {kernel_function}Async(string request);
```

Frame types per agent:
- `OrchestratorFrame` — orchestrator-agent
- `PlannerFrame` — planner-agent
- `MakerFrame` — maker-agent
- `CheckerFrame` — checker-agent
- `ReflectorFrame` — reflector-agent

---

## .NET SDK Targets

| Scenario | Target Framework |
|:---------|:----------------|
| New Colony agents (production) | `net9.0` |
| MAF package minimum | `net8.0` |
| Legacy compatibility | `netstandard2.0` / `net472` |

> Always target `net9.0` for new Colony work. MAF 1.7.0 is fully compatible.

---

## Quick-Start .csproj (Colony Agent Host)

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net9.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>

  <ItemGroup>
    <!-- MAF Core -->
    <PackageReference Include="Microsoft.Agents.AI"          Version="1.7.0" />
    <PackageReference Include="Microsoft.Agents.AI.Hosting"  Version="1.7.0" />
    <PackageReference Include="Microsoft.Agents.AI.Workflows" Version="1.7.0" />

    <!-- Provider (pick one) -->
    <PackageReference Include="Microsoft.Agents.AI.OpenAI"   Version="1.7.0" />

    <!-- Optional: Dev UI for local debugging -->
    <PackageReference Include="Microsoft.Agents.AI.DevUI"    Version="1.7.0" />
  </ItemGroup>
</Project>
```

---

## Sources

| Source | URL | Date Validated |
|:-------|:----|:---------------|
| MAF 1.0 GA blog post | devblogs.microsoft.com/agent-framework/microsoft-agent-framework-version-1-0/ | 2026-06-19 |
| NuGet: Microsoft.Agents.AI 1.7.0 | nuget.org/packages/Microsoft.Agents.AI | 2026-06-19 |
| GitHub releases | github.com/microsoft/agent-framework/releases | 2026-06-19 |
| MS Learn overview | learn.microsoft.com/en-us/agent-framework/overview/ | 2026-06-19 |
| MAF blog | devblogs.microsoft.com/agent-framework/ | 2026-06-19 |
