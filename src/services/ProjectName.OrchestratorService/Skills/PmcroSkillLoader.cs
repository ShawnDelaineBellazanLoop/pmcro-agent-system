#nullable enable
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Frozen;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Text.Json;

namespace ProjectName.OrchestratorService.Skills;

public sealed record AgentSkill(
    string AgentName,
    string Description,
    string Version,
    string FullText,
    string SystemPrompt,
    string? DomainConfigJson,
    FrozenDictionary<string, string> Prompts
);

public sealed class PmcroSkillLoader(ILogger<PmcroSkillLoader> logger)
{
    private FrozenDictionary<string, AgentSkill> _skills = FrozenDictionary<string, AgentSkill>.Empty;

    public IReadOnlyList<string> Advertise() => _skills.Values.Select(s => $"{s.AgentName}: {s.Description}").ToList();
    public AgentSkill? GetSkill(string name) => _skills.TryGetValue(name, out var s) ? s : null;
    public IEnumerable<AgentSkill> GetAllSkills() => _skills.Values;

    public string? GetSystemPrompt(string name) => _skills.TryGetValue(name, out var s) ? s.SystemPrompt : null;

    public void LoadAll(string? identityPath = null)
    {
        var asm = Assembly.GetExecutingAssembly();
        var resources = asm.GetManifestResourceNames()
            .Where(n => n.EndsWith("SKILL.md", StringComparison.OrdinalIgnoreCase));

        var dict = new Dictionary<string, AgentSkill>(StringComparer.OrdinalIgnoreCase);

        foreach (var res in resources)
        {
            var parts = res.Split('.');
            var agentName = parts.Length >= 2 ? parts[parts.Length - 2] : "unknown";

            using var stream = asm.GetManifestResourceStream(res);
            if (stream == null) continue;
            using var reader = new StreamReader(stream);
            var text = reader.ReadToEnd();

            dict[agentName] = new AgentSkill(agentName, "PMCRO Agent", "1.0.0", text, text, null, FrozenDictionary<string, string>.Empty);
        }
        _skills = dict.ToFrozenDictionary(StringComparer.OrdinalIgnoreCase);
        logger.LogInformation("[SkillLoader] {Count} skills loaded into memory.", _skills.Count);
    }
}