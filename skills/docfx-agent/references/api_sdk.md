# Docfx.App Programmatic SDK Reference

> DocFX 2.78.5 | Validated 2026-06-19  
> Source: dotnet.github.io/docfx — "Use DocFX as a library"

## Overview

`Docfx.App` NuGet package exposes a programmatic API for embedding DocFX builds inside
.NET applications, background services, build tasks, and CI orchestrators without shelling out to the CLI.

**Two-phase API:**
1. `DotnetApiCatalog.GenerateManagedReferenceYamlFiles(configPath)` — metadata phase
2. `Docset.Build(configPath)` — build phase

## .csproj — DocBuildHost Project

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net9.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <AssemblyName>{{company}}.DocBuildHost</AssemblyName>
    <!-- Required: generate XML doc from this host project -->
    <GenerateDocumentationFile>false</GenerateDocumentationFile>
  </PropertyGroup>

  <ItemGroup>
    <!--
      CRITICAL: Microsoft.CodeAnalysis.*.Workspaces MUST match the exact version
      that Docfx.App 2.78.5 was built against. Do NOT update independently.
      Check https://www.nuget.org/packages/Docfx.App for the pinned version.
    -->
    <PackageReference Include="Docfx.App" Version="2.78.5" />
    <PackageReference Include="Microsoft.CodeAnalysis.Workspaces.MSBuild" Version="4.10.0" />
    <PackageReference Include="Microsoft.CodeAnalysis.CSharp.Workspaces" Version="4.10.0" />
  </ItemGroup>

</Project>
```

## Program.cs — Minimal Entry Point

```csharp
using Docfx;
using Docfx.Dotnet;

// Path to your docfx.json (relative to this executable or absolute)
const string configPath = "docs/docfx.json";

// Phase 1: Extract API metadata from .NET source code → YAML files
await DotnetApiCatalog.GenerateManagedReferenceYamlFiles(configPath);

// Phase 2: Build the static site from YAML + Markdown
await Docset.Build(configPath);

Console.WriteLine("Documentation build complete.");
```

## Program.cs — Production Entry Point (with options, logging, cancellation)

```csharp
using Docfx;
using Docfx.Dotnet;
using Microsoft.Extensions.Logging;

var cts = new CancellationTokenSource();
Console.CancelKeyPress += (_, e) =>
{
    e.Cancel = true;
    cts.Cancel();
};

var configPath = args.Length > 0 ? args[0] : "docs/docfx.json";

using var loggerFactory = LoggerFactory.Create(builder =>
    builder.AddConsole().SetMinimumLevel(LogLevel.Information));

var logger = loggerFactory.CreateLogger("DocBuildHost");
logger.LogInformation("Starting DocFX build: {ConfigPath}", configPath);

try
{
    // Phase 1: Metadata
    logger.LogInformation("Phase 1: Generating managed reference YAML files...");
    await DotnetApiCatalog.GenerateManagedReferenceYamlFiles(configPath, new DotnetApiOptions
    {
        // Optional: suppress progress output to reduce noise in structured log pipelines
        // Properties can be used to override MSBuild properties programmatically
    });

    // Phase 2: Build
    logger.LogInformation("Phase 2: Building documentation site...");
    await Docset.Build(configPath, new BuildOptions
    {
        // ConfigureMarkdig = pipeline => pipeline.UseSmartyPants()
    });

    logger.LogInformation("Documentation build complete.");
}
catch (OperationCanceledException)
{
    logger.LogWarning("Build cancelled.");
    return 1;
}
catch (Exception ex)
{
    logger.LogError(ex, "Documentation build failed.");
    return 2;
}

return 0;
```

## Integration: .NET Generic Host (ASP.NET Core / Worker Service)

```csharp
// In Program.cs of an ASP.NET Core or Worker Service project
builder.Services.AddHostedService<DocBuildWorker>();

// DocBuildWorker.cs
public class DocBuildWorker : BackgroundService
{
    private readonly ILogger<DocBuildWorker> _logger;
    private readonly IConfiguration _config;

    public DocBuildWorker(ILogger<DocBuildWorker> logger, IConfiguration config)
    {
        _logger = logger;
        _config = config;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var configPath = _config["DocFx:ConfigPath"] ?? "docs/docfx.json";

        _logger.LogInformation("DocFX build starting: {Path}", configPath);

        await DotnetApiCatalog.GenerateManagedReferenceYamlFiles(configPath);
        await Docset.Build(configPath);

        _logger.LogInformation("DocFX build complete.");
    }
}
```

## MSBuild Task Integration

For teams wanting DocFX as a build step inside `.csproj`:

```xml
<!-- In your documentation .csproj, add as a post-build target -->
<Target Name="GenerateDocs" AfterTargets="Build" Condition="'$(GenerateDocs)' == 'true'">
  <Exec Command="dotnet tool run docfx docs/docfx.json" />
</Target>
```

Invoke with: `dotnet build -p:GenerateDocs=true`

## Common Issues & Fixes

| Issue | Cause | Fix |
|:------|:------|:----|
| `MSBuildWorkspace` fails to load project | Roslyn version mismatch | Pin `Microsoft.CodeAnalysis.*.Workspaces` to `4.10.0` exactly |
| `ArgumentException` on empty namespace | Namespace has only internal types + default filter | Add namespace to `filterConfig.yml` includes, or use `--disableDefaultFilter` |
| Metadata generation succeeds but no API pages | `dest` path in `docfx.json` not referenced in `build.content` | Ensure `api/**` is covered by `build.content` glob |
| Slow builds on large monorepos | git feature scan on thousands of commits | Set `"disableGitFeatures": true` in metadata section |
| `dotnet restore` required even with no NuGet deps | MSBuildWorkspace needs project assets | Always run `dotnet restore` before generating metadata |
