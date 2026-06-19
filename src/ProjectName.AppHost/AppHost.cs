var builder = DistributedApplication.CreateBuilder(args);

// ── Ollama — Persistent GPU container (survives AppHost restarts) ─────────────
var ollama = builder
    .AddOllama("ollama-server")
    .WithGPUSupport(OllamaGpuVendor.Nvidia)
    .WithLifetime(ContainerLifetime.Persistent)
    .WithDataVolume();                        // persist pulled model layers across restarts

var modelOrchestrator = ollama.AddModel("model-orchestrator", "qwen3:8b");

// ── Orchestrator Service — waits for model to be healthy before starting ──────
var orchestratorService = builder
    .AddProject<Projects.ProjectName_OrchestratorService>("orchestratorservice")
    .WithReference(ollama)                    // connection string to Ollama HTTP endpoint
    .WithReference(modelOrchestrator)         // model resource reference for health gate
    .WithEnvironment("Orchestrator__MaxLoops", "3")
    .WaitFor(modelOrchestrator);              // blocked until qwen3:8b pull + health check pass

// ── Orchestrator API ──────────────────────────────────────────────────────────
builder.AddProject<Projects.ProjectName_OrchestratorApi>("orchestratorapi")
    .WithReference(orchestratorService)
    .WithExternalHttpEndpoints();

// ── DevUI Dashboard ───────────────────────────────────────────────────────────
var devUI = builder.AddDevUI("pmcro-devui");
devUI.WithAgentService(orchestratorService);  // wires DevUI agent discovery to OrchestratorService
devUI.WithHttpEndpoint(targetPort: 8080, name: "devui").WithExternalHttpEndpoints();

builder.Build().Run();