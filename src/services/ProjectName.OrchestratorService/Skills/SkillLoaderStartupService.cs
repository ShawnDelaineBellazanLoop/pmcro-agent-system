using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;

namespace ProjectName.OrchestratorService.Skills;

public sealed class SkillLoaderStartupService(PmcroSkillLoader loader) : IHostedService
{
    public Task StartAsync(CancellationToken cancellationToken)
    {
        loader.LoadAll();
        return Task.CompletedTask;
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
}