namespace ProjectName.OrchestratorService.Configuration;

/// <summary>
/// Orchestrator runtime configuration.
/// GTDDD-MANDATE: every value here is sourced from appsettings.json / environment —
/// no hardcoded paths or limits in code.
/// </summary>
public sealed class OrchestratorConfig
{
    public const string SectionName = "Orchestrator";

    /// <summary>Root path of the PMCR-O filesystem (skills/, .pmcro/, trails, etc.)</summary>
    public required string FileSystemRoot { get; set; }

    /// <summary>EC-009: maximum cognitive loop iterations before forced HALT.</summary>
    public int MaxLoops { get; set; } = 3;

    /// <summary>Ollama model identifier bound to this orchestrator instance.</summary>
    public string ModelId { get; set; } = "qwen3:8b";
}
