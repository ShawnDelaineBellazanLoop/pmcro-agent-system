# CI/CD Patterns Reference

> DocFX 2.78.5 | Validated 2026-06-19

## GitHub Actions — Deploy to GitHub Pages (Production Pattern)

```yaml
# .github/workflows/docs.yml
name: Deploy Documentation

on:
  push:
    branches: [main]
    paths:
      - 'src/**'
      - 'docs/**'
      - '.github/workflows/docs.yml'
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: false

jobs:
  build-docs:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0          # Required for git-based metadata (_gitContribute links)

      - name: Setup .NET 9
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '9.x'

      - name: Restore .NET tool manifest
        run: dotnet tool restore
        # Reads .config/dotnet-tools.json — installs docfx 2.78.5 reproducibly

      - name: Restore solution dependencies
        run: dotnet restore {{solution-path}}

      - name: Build documentation
        run: docfx docs/docfx.json --warningsAsErrors

      - name: Upload Pages artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: docs/_site

  deploy-docs:
    needs: build-docs
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

## GitHub Actions — Deploy to Azure Static Web Apps

```yaml
# .github/workflows/docs-azure.yml
name: Deploy Documentation to Azure

on:
  push:
    branches: [main]
  pull_request:
    types: [opened, synchronize, reopened, closed]
    branches: [main]

jobs:
  build-and-deploy:
    if: github.event_name == 'push' || (github.event_name == 'pull_request' && github.event.action != 'closed')
    runs-on: ubuntu-latest
    name: Build and Deploy
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup .NET 9
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '9.x'

      - name: Restore tool manifest
        run: dotnet tool restore

      - name: Restore dependencies
        run: dotnet restore {{solution-path}}

      - name: Build documentation
        run: docfx docs/docfx.json --warningsAsErrors

      - name: Deploy to Azure Static Web Apps
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: upload
          app_location: docs/_site
          skip_app_build: true

  close-pr:
    if: github.event_name == 'pull_request' && github.event.action == 'closed'
    runs-on: ubuntu-latest
    name: Close Pull Request
    steps:
      - name: Close Pull Request
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          action: close
```

## Azure Pipelines

```yaml
# azure-pipelines-docs.yml
trigger:
  branches:
    include: [main]
  paths:
    include: [src/*, docs/*]

pool:
  vmImage: ubuntu-latest

variables:
  DOTNET_VERSION: '9.x'

steps:
  - checkout: self
    fetchDepth: 0   # Full history for git metadata

  - task: UseDotNet@2
    displayName: 'Install .NET 9 SDK'
    inputs:
      version: $(DOTNET_VERSION)
      includePreviewVersions: false

  - script: dotnet tool restore
    displayName: 'Restore DocFX 2.78.5 from dotnet-tools.json'

  - script: dotnet restore {{solution-path}}
    displayName: 'Restore solution'

  - script: docfx docs/docfx.json --warningsAsErrors
    displayName: 'Build DocFX site'

  - task: AzureStaticWebApp@0
    displayName: 'Deploy to Azure Static Web Apps'
    inputs:
      app_location: 'docs/_site'
      skip_app_build: true
    env:
      AZURE_STATIC_WEB_APPS_API_TOKEN: $(AZURE_STATIC_WEB_APPS_API_TOKEN)
```

## Key CI/CD Best Practices

### Always use `fetch-depth: 0`
DocFX reads git history to generate "last modified" dates and "Edit on GitHub" links.
A shallow clone (`fetch-depth: 1`, the default) breaks this. Use `fetch-depth: 0`.

### Pin DocFX via dotnet-tools.json
Avoid `dotnet tool update -g docfx` in CI — the "latest" version changes without warning.
Use `.config/dotnet-tools.json` + `dotnet tool restore` for reproducible builds.

### Run `dotnet restore` before `docfx`
DocFX uses MSBuildWorkspace to load projects. Dependencies must be present.
Even if the project has no NuGet packages and Visual Studio is not installed, run restore.

### `--warningsAsErrors` in CI
Broken xrefs, unresolved UIDs, and missing articles become CI failures.
This is the enterprise standard — documentation quality is enforced at the gate.

### Shallow clone optimization for large repos
If git history must be shallow for performance, set `"disableGitFeatures": true`
in `docfx.json` under the `metadata` section to skip git-based metadata extraction.
This trades off "Edit on GitHub" links and last-modified dates for build speed.

### Ubuntu runners for cost efficiency
- Ubuntu: 1× cost multiplier
- Windows: 2× cost multiplier
- macOS: 10× cost multiplier

DocFX 2.78.5 runs on all three platforms. Use Ubuntu for CI unless Windows-only
SDK components or build scripts require it.
