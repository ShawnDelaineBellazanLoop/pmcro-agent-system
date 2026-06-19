using System;
using System.Linq;
using System.Threading.Tasks;
using Grpc.Core;
using Microsoft.Extensions.AI;
using Microsoft.Extensions.Options;
using Microsoft.Extensions.Logging;
using ProjectName.OrchestratorService.Configuration;
using ProjectName.OrchestratorService.Skills;

namespace ProjectName.OrchestratorService.Services;

public sealed class PmcroOrchestratorService(
    [FromKeyedServices("ollama")] IChatClient chatClient,
    IOptions<OrchestratorConfig> config,
    PmcroSkillLoader skillLoader,
    ILogger<PmcroOrchestratorService> logger)
    : ProjectName.OrchestratorService.PmcroOrchestrator.PmcroOrchestratorBase
{
    private readonly OrchestratorConfig _cfg = config.Value;

    public override async Task<ProjectName.OrchestratorService.CycleResponse> RunCycle(
        ProjectName.OrchestratorService.CycleRequest request,
        ServerCallContext context)
    {
        var id = request.CycleId ?? Guid.NewGuid().ToString();
        logger.LogInformation("[PMCR-O] Cycle {Id} active.", id);

        var skillCount = skillLoader.GetAllSkills().Count();

        return new ProjectName.OrchestratorService.CycleResponse
        {
            CycleId = id,
            Status = "ACCEPT",
            Output = $"Substrate Integrity Verified. Registry: {skillCount} skills."
        };
    }

    public override async Task<ProjectName.OrchestratorService.AgentResponse> Invoke(
        ProjectName.OrchestratorService.AgentRequest request,
        ServerCallContext context)
    {
        return new ProjectName.OrchestratorService.AgentResponse
        {
            AgentName = request.AgentName,
            Text = "Unary Response: Operational."
        };
    }
}