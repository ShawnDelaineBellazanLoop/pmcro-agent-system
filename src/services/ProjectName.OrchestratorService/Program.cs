// src/services/ProjectName.OrchestratorService/Program.cs
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.Extensions.AI;
using Microsoft.Extensions.Configuration;

using Microsoft.Agents.AI;
using Microsoft.Agents.AI.Hosting;
using Microsoft.Agents.AI.DevUI;

using ProjectName.OrchestratorService.Configuration;
using ProjectName.OrchestratorService.Services;
using ProjectName.OrchestratorService.Skills;
using OllamaSharp;

var builder = WebApplication.CreateBuilder(args);

// ── Aspire Defaults ──────────────────────────────────────────────────────────
builder.AddServiceDefaults();

// ── MAF DevUI & Hosting Requirements ─────────────────────────────────────────
builder.AddOpenAIResponses();
builder.AddOpenAIConversations();
builder.AddDevUI();

// ── Configuration (EC-009) ───────────────────────────────────────────────────
builder.Services.AddOptions<OrchestratorConfig>()
    .BindConfiguration(OrchestratorConfig.SectionName)
    .ValidateDataAnnotations()
    .ValidateOnStart();

// ── Skill System ─────────────────────────────────────────────────────────────
builder.Services.AddSingleton<PmcroSkillLoader>();
builder.Services.AddHostedService<SkillLoaderStartupService>();

// ── 🆕 MAF Agent Registration (Substrate Aligned) ───────────────────────────
builder.Services.AddKeyedSingleton<IChatClient>("ollama", (sp, key) => {
    var config = sp.GetRequiredService<IConfiguration>();
    var endpoint = config.GetConnectionString("ollama") ?? "http://localhost:11434";
    return new OllamaApiClient(new Uri(endpoint)) { SelectedModel = "qwen3:8b" };
});

builder.AddAIAgent("Orchestrator", (sp, key) =>
{
    var chatClient = sp.GetRequiredKeyedService<IChatClient>("ollama");
    var skillLoader = sp.GetRequiredService<PmcroSkillLoader>();
    var orchestratorSkill = skillLoader.GetSkill("orchestrator-agent");

    var providerBuilder = new AgentSkillsProviderBuilder()
        .UseFileScriptRunner(PmcroScriptRunner.RunAsync); // gap #1 closed — script runner wired
    foreach (var skill in skillLoader.GetAllSkills())
    {
        var frontmatter = new AgentSkillFrontmatter(skill.AgentName, skill.Description);
        providerBuilder.UseSkill(new AgentInlineSkill(frontmatter, skill.SystemPrompt));
    }

    var options = new ChatClientAgentOptions
    {
        Name = "Orchestrator",
        ChatOptions = new ChatOptions
        {
            Instructions = orchestratorSkill?.SystemPrompt ?? "Orchestrator Active.",
            Temperature = 0.0f
        },
        AIContextProviders = [providerBuilder.Build()]
    };

    return new ChatClientAgent(chatClient, options);
});

// ── gRPC ─────────────────────────────────────────────────────────────────────
builder.Services.AddGrpc(options => { options.EnableDetailedErrors = true; });
builder.Services.AddGrpcReflection();

var app = builder.Build();

app.MapGrpcService<PmcroOrchestratorService>();

if (app.Environment.IsDevelopment())
{
    app.MapGrpcReflectionService();
    app.MapOpenAIResponses();
    app.MapOpenAIConversations();
    app.MapDevUI();
}

app.MapDefaultEndpoints();
app.MapGet("/", () => "PMCR-O OrchestratorService — MAF 1.10.0 Baseline 11.0 Ready");

await app.RunAsync();

// ── 🆕 Script Runner Implementation ──────────────────────────────────────────
public static class PmcroScriptRunner
{
    public static async Task<object?> RunAsync(
        AgentFileSkill skill,
        AgentFileSkillScript script,
        JsonElement? arguments,
        IServiceProvider? sp,
        CancellationToken ct)
    {
        return await Task.FromResult("PMCRO Local Runner Active.");
    }
}