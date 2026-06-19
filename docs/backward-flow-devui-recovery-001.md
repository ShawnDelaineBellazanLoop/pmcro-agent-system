# PMCR-O BACKWARD FLOW — Recovery Activation Prompt
# Agent:      orchestrator-agent → maker-agent → filesystem-agent → devops-agent
# Mode:       O-MODE: RECOVER
# Trail:      backward-flow-devui-recovery-001
# Schema:     2.0
# Version:    1.0.0
# Triggered:  Source application deleted — reconstruct from session crystallization
# ============================================================

## SYSTEM FRAME (Load before first tool call)

```json
{
  "trail_id": "backward-flow-devui-recovery-001",
  "cycle": 0,
  "o_mode": "RECOVER",
  "intent": "Reconstruct the deleted PMCR-O OrchestratorService application from session-crystallized ground truth",
  "backward_flow_source": "saveme.zip — Gemini session transcript confirming working build state",
  "earned_constraints": [
    "EC-SYS-001: Every file written MUST be complete — no stubs, no truncation",
    "EC-SYS-003: Write trail frame to .pmcro/trails/ before marking cycle complete",
    "DEVOPS-002: Verify dotnet --version matches global.json before any build",
    "DEVOPS-001: Non-zero exit code = FAILED — no success inference",
    "GTDDD-MANDATE: Zero hardcoded values — all tokens via identity.json"
  ],
  "ground_truth_locked": true,
  "ground_truth_source": "Microsoft.Agents.AI.dll decompiled — AgentFileSkillScriptRunner confirmed 5-param delegate"
}
```

---

## ORCHESTRATOR ROUTING FRAME

```json
{
  "frame_type": "OrchestratorFrame",
  "trail_id": "backward-flow-devui-recovery-001",
  "intent": "Reconstruct ProjectName.OrchestratorService with working DevUI, clean build, and live Ollama binding",
  "subject_agent": "maker-agent",
  "domain_config": "skills/filesystem-agent/domain_config.json",
  "o_mode": "RECOVER",
  "phase_sequence": ["PLAN", "MAKE", "CHECK", "REFLECT"],
  "max_loops": 3,
  "hil_gate": "BEFORE_DOTNET_PUBLISH",
  "trail_owner": "orchestrator-agent"
}
```

---

## PLANNER FRAME — Reconstruction Decomposition

```json
{
  "frame_type": "PlannerFrame",
  "trail_id": "backward-flow-devui-recovery-001",
  "cycle": 1,
  "intent": "Reconstruct the PMCR-O OrchestratorService DevUI application",
  "certified": false,
  "steps": [
    {
      "step_id": "STEP-001",
      "domain_action": "fs_write_file",
      "description": "Write Directory.Packages.props with locked package versions from ground truth",
      "target_path": "C:\\Users\\org.tooensure\\source\\repos\\ShawnDelaineBellazanLoop\\pmcro-agent-system\\Directory.Packages.props",
      "type": "TYPE1",
      "hil_required": true,
      "dependency": null
    },
    {
      "step_id": "STEP-002",
      "domain_action": "fs_write_file",
      "description": "Write ProjectName.slnx solution file referencing all projects",
      "target_path": "C:\\Users\\org.tooensure\\source\\repos\\ShawnDelaineBellazanLoop\\pmcro-agent-system\\ProjectName.slnx",
      "type": "TYPE1",
      "hil_required": true,
      "dependency": null
    },
    {
      "step_id": "STEP-003",
      "domain_action": "fs_write_file",
      "description": "Write global.json with .NET 10 SDK pin",
      "target_path": "C:\\Users\\org.tooensure\\source\\repos\\ShawnDelaineBellazanLoop\\pmcro-agent-system\\global.json",
      "type": "TYPE1",
      "hil_required": true,
      "dependency": null
    },
    {
      "step_id": "STEP-004",
      "domain_action": "fs_write_file",
      "description": "Write AppHost Program.cs — Aspire orchestration entry point",
      "target_path": "src\\hosts\\ProjectName.AppHost\\Program.cs",
      "type": "TYPE1",
      "hil_required": true,
      "dependency": "STEP-001"
    },
    {
      "step_id": "STEP-005",
      "domain_action": "fs_write_file",
      "description": "Write OrchestratorService Program.cs — GROUND TRUTH: builder.AddChatClientAgent + 5-param AgentFileSkillScriptRunner",
      "target_path": "src\\services\\ProjectName.OrchestratorService\\Program.cs",
      "type": "TYPE1",
      "hil_required": true,
      "dependency": "STEP-001",
      "critical_constraint": "GROUND_TRUTH_LOCKED — see Ground Truth section below"
    },
    {
      "step_id": "STEP-006",
      "domain_action": "fs_write_file",
      "description": "Write OrchestratorService .csproj with MAF package references",
      "target_path": "src\\services\\ProjectName.OrchestratorService\\ProjectName.OrchestratorService.csproj",
      "type": "TYPE1",
      "hil_required": true,
      "dependency": "STEP-001"
    },
    {
      "step_id": "STEP-007",
      "domain_action": "fs_write_file",
      "description": "Write PmcroSkillLoader.cs — loads SKILL.md files from S:\\skills registry",
      "target_path": "src\\services\\ProjectName.OrchestratorService\\Skills\\PmcroSkillLoader.cs",
      "type": "TYPE1",
      "hil_required": true,
      "dependency": "STEP-005"
    },
    {
      "step_id": "STEP-008",
      "domain_action": "fs_write_file",
      "description": "Write SkillLoaderStartupService.cs — IHostedService that loads skills on startup",
      "target_path": "src\\services\\ProjectName.OrchestratorService\\Skills\\SkillLoaderStartupService.cs",
      "type": "TYPE1",
      "hil_required": true,
      "dependency": "STEP-007"
    },
    {
      "step_id": "STEP-009",
      "domain_action": "fs_write_file",
      "description": "Write OrchestratorConfig.cs — configuration POCO with FileSystemRoot and EC-009 MaxLoops",
      "target_path": "src\\services\\ProjectName.OrchestratorService\\Configuration\\OrchestratorConfig.cs",
      "type": "TYPE1",
      "hil_required": true,
      "dependency": "STEP-005"
    },
    {
      "step_id": "STEP-010",
      "domain_action": "fs_write_file",
      "description": "Write PmcroOrchestratorService.cs — gRPC service implementation",
      "target_path": "src\\services\\ProjectName.OrchestratorService\\Services\\PmcroOrchestratorService.cs",
      "type": "TYPE1",
      "hil_required": true,
      "dependency": "STEP-005"
    },
    {
      "step_id": "STEP-011",
      "domain_action": "fs_write_file",
      "description": "Write ServiceDefaults project — OllamaExtensions with Keys.Orchestrator",
      "target_path": "src\\shared\\ProjectName.ServiceDefaults\\OllamaExtensions.cs",
      "type": "TYPE1",
      "hil_required": true,
      "dependency": "STEP-001"
    },
    {
      "step_id": "STEP-012",
      "domain_action": "fs_write_file",
      "description": "Write appsettings.json for OrchestratorService — FileSystemRoot, Ollama endpoint, EC-009 MaxLoops",
      "target_path": "src\\services\\ProjectName.OrchestratorService\\appsettings.json",
      "type": "TYPE1",
      "hil_required": true,
      "dependency": "STEP-009"
    },
    {
      "step_id": "STEP-013",
      "domain_action": "mk_sdk_verify",
      "description": "Verify dotnet --version matches global.json SDK pin (DEVOPS-002)",
      "type": "TYPE2",
      "hil_required": false,
      "dependency": "STEP-003"
    },
    {
      "step_id": "STEP-014",
      "domain_action": "mk_build",
      "description": "dotnet build — confirm clean build before AppHost launch",
      "type": "TYPE2",
      "hil_required": false,
      "dependency": "STEP-013"
    }
  ]
}
```

---

## ⚠️ GROUND TRUTH — DO NOT DEVIATE

The following is crystallized from the physical decompiled DLL on the target machine.
All downstream agents MUST use these exact signatures. Any deviation triggers HIL_ESCALATE.

### 1. AgentFileSkillScriptRunner — Exact 5-Parameter Delegate

```csharp
// From: Microsoft.Agents.AI.dll, Version=1.10.0.0
// Decompiled and confirmed by user from NuGet cache

public delegate Task<object?> AgentFileSkillScriptRunner(
    AgentFileSkill skill,
    AgentFileSkillScript script,
    JsonElement? arguments,         // ← JsonElement?, NOT IDictionary, NOT AIFunctionArguments
    IServiceProvider? serviceProvider,
    CancellationToken cancellationToken);
```

### 2. PmcroScriptRunner — Colony Implementation

```csharp
using System.Diagnostics;
using System.Text.Json;
using Microsoft.Agents.AI;

public static class PmcroScriptRunner
{
    public static async Task<object?> RunAsync(
        AgentFileSkill skill,
        AgentFileSkillScript script,
        JsonElement? arguments,
        IServiceProvider? serviceProvider,
        CancellationToken cancellationToken)
    {
        try
        {
            var scriptFilePath = script.FullPath;
            var args = string.Empty;
            if (arguments.HasValue && arguments.Value.ValueKind == JsonValueKind.Object)
            {
                args = string.Join(" ", arguments.Value.EnumerateObject()
                    .Select(p => $"--{p.Name} \"{p.Value}\""));
            }

            var psi = new ProcessStartInfo("python")
            {
                Arguments = $"\"{scriptFilePath}\" {args}",
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false,
                CreateNoWindow = true
            };

            using var process = Process.Start(psi);
            if (process == null) return "Failed to start script process.";

            var output = await process.StandardOutput.ReadToEndAsync(cancellationToken);
            var error = await process.StandardError.ReadToEndAsync(cancellationToken);
            await process.WaitForExitAsync(cancellationToken);

            return process.ExitCode == 0 ? output : $"Error (Exit {process.ExitCode}): {error}";
        }
        catch (Exception ex)
        {
            return $"Script execution failed: {ex.Message}";
        }
    }
}
```

### 3. Agent Registration — builder.AddChatClientAgent (NOT AddKeyedSingleton)

```csharp
// CORRECT — registers in IAgentRegistry, DevUI discoverable
builder.AddChatClientAgent("Orchestrator", (sp) =>
{
    var chatClient = sp.GetRequiredKeyedService<IChatClient>(
        ProjectName.ServiceDefaults.OllamaExtensions.Keys.Orchestrator);
    var config = sp.GetRequiredService<IOptions<OrchestratorConfig>>().Value;
    var skillLoader = sp.GetRequiredService<PmcroSkillLoader>();
    var orchestratorSkill = skillLoader.GetSkill("orchestrator-agent");

    var skillsPath = Path.Combine(config.FileSystemRoot, "skills");

    var provider = new AgentSkillsProviderBuilder()
        .UseFileSkills([skillsPath])
        .UseFileScriptRunner((skill, script, args, serviceProvider, ct) =>
            PmcroScriptRunner.RunAsync(skill, script, args, serviceProvider, ct))
        .Build();

    var options = new ChatClientAgentOptions
    {
        Name = "Orchestrator",
        ChatOptions = new ChatOptions
        {
            Instructions = orchestratorSkill?.SystemPrompt ?? "You are the PMCRO Orchestrator."
        },
        AIContextProviders = [provider]
    };

    return new ChatClientAgent(chatClient, options);
});
```

### 4. Locked Package Versions (Directory.Packages.props)

```xml
<!-- Aspire -->
<PackageVersion Include="Aspire.Hosting.AppHost" Version="13.4.5" />
<PackageVersion Include="CommunityToolkit.Aspire.Hosting.Ollama" Version="13.4.0" />
<PackageVersion Include="Aspire.Hosting.AgentFramework.DevUI" Version="1.10.0-preview.260610.1" />

<!-- MAF Core -->
<PackageVersion Include="Microsoft.Agents.AI" Version="1.10.0" />
<PackageVersion Include="Microsoft.Agents.AI.Workflows" Version="1.10.0" />
<PackageVersion Include="Microsoft.Agents.AI.Abstractions" Version="1.10.0" />
<PackageVersion Include="Microsoft.Agents.AI.OpenAI" Version="1.10.0" />
<PackageVersion Include="Microsoft.Agents.AI.Hosting" Version="1.10.0-preview.260610.1" />
<PackageVersion Include="Microsoft.Agents.AI.DevUI" Version="1.10.0-preview.260610.1" />

<!-- AI -->
<PackageVersion Include="Microsoft.Extensions.AI" Version="10.7.0" />
<PackageVersion Include="Microsoft.Extensions.AI.Abstractions" Version="10.7.0" />
<PackageVersion Include="OllamaSharp" Version="5.4.25" />

<!-- gRPC -->
<PackageVersion Include="Grpc.AspNetCore" Version="2.80.0" />
<PackageVersion Include="Grpc.AspNetCore.Server.Reflection" Version="2.80.0" />
<PackageVersion Include="Grpc.Net.Client" Version="2.80.0" />
<PackageVersion Include="Grpc.Tools" Version="2.82.0-pre1" />
<PackageVersion Include="Google.Protobuf" Version="3.35.1" />

<!-- OpenTelemetry -->
<PackageVersion Include="OpenTelemetry.Exporter.OpenTelemetryProtocol" Version="1.16.0" />
<PackageVersion Include="OpenTelemetry.Extensions.Hosting" Version="1.16.0" />
<PackageVersion Include="OpenTelemetry.Instrumentation.AspNetCore" Version="1.15.2" />
<PackageVersion Include="OpenTelemetry.Instrumentation.Http" Version="1.15.1" />
<PackageVersion Include="OpenTelemetry.Instrumentation.Runtime" Version="1.15.1" />

<!-- Others -->
<PackageVersion Include="Microsoft.Extensions.Http.Resilience" Version="10.7.0" />
<PackageVersion Include="Microsoft.Extensions.ServiceDiscovery" Version="10.7.0" />
<PackageVersion Include="Microsoft.VisualStudio.Azure.Containers.Tools.Targets" Version="1.23.0" />

<!-- OpenAPI / Versioning / Scalar -->
<PackageVersion Include="Microsoft.AspNetCore.OpenApi" Version="10.0.9" />
<PackageVersion Include="Asp.Versioning.Mvc" Version="10.0.0" />
<PackageVersion Include="Asp.Versioning.Mvc.ApiExplorer" Version="10.0.0" />
<PackageVersion Include="Asp.Versioning.OpenApi" Version="10.0.0-rc.1" />
<PackageVersion Include="Scalar.AspNetCore" Version="2.16.4" />
<PackageVersion Include="Scalar.AspNetCore.Microsoft" Version="2.16.4" />
```

### 5. Confirmed Working State (from session transcript)

The DevUI reached this working state:
- Build: ✅ CLEAN (zero errors, zero warnings)  
- DevUI: ✅ LIVE at `http://localhost:XXXX/dev-ui`
- Orchestrator: ✅ Visible in agent dropdown
- Skills: ✅ Loaded from `S:\skills` via `AgentSkillsProvider`
- Ollama: ✅ `qwen3:8b` bound via `IChatClient` keyed service
- gRPC: ✅ `PmcroOrchestratorService` mapped
- OpenTelemetry: ✅ Traces tab active in DevUI

---

## MAKER FRAME DIRECTIVE

```json
{
  "frame_type": "MakerDirective",
  "trail_id": "backward-flow-devui-recovery-001",
  "instruction": "Execute STEP-001 through STEP-012 using filesystem-agent domain_actions. Write each file completely — EC-SYS-001 enforced. After all files written, execute STEP-013 (mk_sdk_verify) then STEP-014 (mk_build). Report BuildFrame after dotnet build. Do NOT proceed to publish or AppHost launch without HIL authorization.",
  "one_file_per_cycle": true,
  "trail_write_required": true,
  "trail_path": ".pmcro/trails/backward-flow-devui-recovery-001.jsonl"
}
```

---

## CHECKER VERIFICATION CRITERIA

```json
{
  "frame_type": "CheckerCriteria",
  "trail_id": "backward-flow-devui-recovery-001",
  "checks": [
    "CHECK-001: Program.cs uses builder.AddChatClientAgent — NOT AddKeyedSingleton<AIAgent>",
    "CHECK-002: PmcroScriptRunner.RunAsync signature = 5 params (AgentFileSkill, AgentFileSkillScript, JsonElement?, IServiceProvider?, CancellationToken)",
    "CHECK-003: AgentSkillsProviderBuilder.UseFileScriptRunner lambda = 5 params matching CHECK-002",
    "CHECK-004: Directory.Packages.props versions match GROUND TRUTH locked versions exactly",
    "CHECK-005: global.json present with sdk.version pinned to .NET 10",
    "CHECK-006: dotnet build exit_code = 0",
    "CHECK-007: No CS1503 or CS1593 errors in build output",
    "CHECK-008: Trail file written to .pmcro/trails/ before cycle marked COMPLETE"
  ]
}
```

---

## REFLECTOR DISPOSITION RULES

```json
{
  "frame_type": "ReflectorRules",
  "trail_id": "backward-flow-devui-recovery-001",
  "rules": [
    {
      "condition": "ALL checks PASS + exit_code = 0",
      "disposition": "COMPLETE",
      "next_action": "HIL — confirm AppHost launch authorization"
    },
    {
      "condition": "CS1503 or CS1593 in build output",
      "disposition": "HALT",
      "earned_constraint": "GROUND_TRUTH_DELEGATE_MISMATCH — re-read Ground Truth section, do NOT guess delegate params",
      "next_action": "HIL_ESCALATE — paste exact compiler error to human before retry"
    },
    {
      "condition": "Agent 'Orchestrator' not found in DevUI",
      "disposition": "RETRY",
      "earned_constraint": "DEVUI_REGISTRATION_MISMATCH — must use builder.AddChatClientAgent, not AddKeyedSingleton",
      "next_action": "Fix Program.cs registration, rebuild, relaunch"
    },
    {
      "condition": "exit_code != 0 on second consecutive build",
      "disposition": "HALT",
      "next_action": "HIL_ESCALATE — full stdout/stderr required in escalation frame"
    }
  ]
}
```

---

## ACTIVATION INSTRUCTIONS

To activate this Backward Flow, paste the following into the DevUI (once live) or into this Claude session:

```
/orchestrator-agent

BACKWARD FLOW ACTIVATION — trail: backward-flow-devui-recovery-001

Load the frame at: S:\docs\backward-flow-devui-recovery-001.md

Execute from STEP-001. Write one file per cycle. Log every cycle to .pmcro/trails/. 
Do not invent delegate signatures — Ground Truth is locked in the frame.
HIL gate before dotnet publish or AppHost launch.
Report BuildFrame after dotnet build completes.
```
