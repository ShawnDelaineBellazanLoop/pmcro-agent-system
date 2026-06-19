# Validated Versions Reference

> Source-verified: 2026-06-19  
> Sources: NuGet Gallery, GitHub dotnet/docfx Releases, dotnet.github.io/docfx

## DocFX Tool & SDK

| Package | Version | Install Command |
|:--------|:--------|:----------------|
| `docfx` (.NET global tool) | **2.78.5** | `dotnet tool update -g docfx` |
| `Docfx.App` (NuGet SDK) | **2.78.5** | `<PackageReference Include="Docfx.App" Version="2.78.5" />` |

## Pinned Roslyn Dependencies (MUST match Docfx.App exactly)

When using `Docfx.App` programmatically, these two packages **must** be pinned to the
exact version that `Docfx.App` 2.78.5 was built against — not the latest stable:

```xml
<PackageReference Include="Docfx.App" Version="2.78.5" />
<PackageReference Include="Microsoft.CodeAnalysis.Workspaces.MSBuild" Version="4.10.0" />
<PackageReference Include="Microsoft.CodeAnalysis.CSharp.Workspaces" Version="4.10.0" />
```

Using mismatched Roslyn versions causes `MSBuildWorkspace` load failures.

## .NET SDK Requirements

| Scenario | Minimum | Recommended |
|:---------|:--------|:------------|
| Running `docfx` tool | .NET 8 SDK | .NET 9 SDK |
| `Docfx.App` programmatic | `net8.0` TFM | `net9.0` TFM |
| Target framework in `metadata.src` | `net8.0` | `net9.0` (`net10.0` supported as of 2.78.5) |

> DocFX 2.78.x **drops .NET 6 support**. Do NOT target `net6.0` or `netstandard2.0`.  
> `.slnx` solution files (new in .NET 9) are supported from 2.78.x onward.
> **2.78.5** (current latest, released 2026-02-24) added `.NET 10` target framework support — confirmed via `dotnet/docfx` GitHub releases.

## Node.js

Node.js is **no longer required** to run `docfx` as of 2.78.x — it was removed from
runtime dependencies. Node.js 24.x is only needed if you are contributing to DocFX
itself and need to build the built-in templates from source.

## dotnet-tools.json (Reproducible Team Installs)

Pin the tool version for consistent builds across all developers and CI agents:

```json
{
  "version": 1,
  "isRoot": true,
  "tools": {
    "docfx": {
      "version": "2.78.5",
      "commands": ["docfx"]
    }
  }
}
```

Install with: `dotnet tool restore`

> **EC-MANIFEST-PATH:** `dotnet new tool-manifest` writes `dotnet-tools.json` to the
> CWD root — NOT to `.config/dotnet-tools.json`. When checking existence in scripts,
> resolve the path as `Join-Path $DocfxRoot 'dotnet-tools.json'` after
> `Push-Location $DocfxRoot`. Checking `.config\dotnet-tools.json` will always miss it
> and re-bootstrap on every run.

## Built-in Templates

| Template Name | Description |
|:-------------|:------------|
| `default` | Base template (always include first) |
| `modern` | Recommended overlay — dark mode, responsive, feature-rich |
| `default(zh-cn)` | Chinese localization overlay |
| `statictoc` | Legacy static TOC template |
| `pdf` | PDF-specific rendering template |

Recommended config: `"template": ["default", "modern"]`

## Release Notes Highlights (2.78.x series)

- .NET 9 support added; .NET 6 dropped
- HTML encoding changed to UTF-8N (without BOM)
- Node.js runtime dependency removed from the `docfx` tool
- New `UseClrTypeNames` option: output CLR type names (`System.String`) instead of language aliases (`string`)
- `pdfHeaderTemplate` / `pdfFooterTemplate` now accept file paths
- `.slnx` solution file support (.NET 9+)
- `CancellationToken` support in `RunBuild.Exec`
- Improved `.NET 9` MSBuild workspace compatibility

---

## EarnedConstraints (Validated 2026-06-19 via live build)

These constraints were discovered by running the actual build and are now permanent
Colony knowledge for all future docfx-agent work.

| ID | Constraint | Rule |
|:---|:-----------|:-----|
| **EC-MANIFEST-PATH** | Tool manifest location | `dotnet new tool-manifest` writes to `<cwd>/dotnet-tools.json`, not `.config/dotnet-tools.json`. Always `Push-Location $DocfxRoot` before checking. |
| **EC-NO-SRC-METADATA** | Skip metadata when no C# src | `metadata` block in `docfx.json` + `dotnet tool run docfx metadata` both emit warnings when `S:\src` has no `.csproj` files. Omit the `metadata` block and skip the metadata phase entirely until C# API reference is needed. |
| **EC-FILTERCONFIG-GLOB** | Exclude filterConfig.yml from content | `filterConfig.yml` matches `**/*.yml` and triggers `MissingYamlMime` warning. Must be in the `exclude` list of the `build.content` block in `docfx.json`. |
| **EC-NO-API-TOC** | No API Reference in toc.yml without src | `toc.yml` entry pointing to `api/` or `api/index.md` causes `InvalidFileLink` and `Unable to find` warnings when no metadata has been generated. Remove the `API Reference` entry until `S:\src` is populated. |
| **EC-NO-SITEMAP-TOKENS** | No unresolved tokens in sitemap.baseUrl | `sitemap.baseUrl` containing `{{company}}` is an invalid URI at build time. Omit the `sitemap` block until token resolution is wired into the build pipeline. |
| **EC-SERVE-REQUIRED** | `_site/index.html` must be served over HTTP, never opened via `file://` | The modern template's navbar items, sidebar TOC, breadcrumb, and search are populated client-side at runtime via `fetch('toc.json')` / `fetch(searchIndex)` inside `docfx.min.js`. Browsers block `fetch` against `file://` paths (CORS), so opening `_site\index.html` directly by double-click shows an empty `<div id="navbar">` (only the disabled search box renders) even though the build succeeded and `toc.json` is fully populated. Always run `serve.ps1` (`dotnet tool run docfx <docfx.json> --serve --port 8080`) or any static HTTP server and view via `http://localhost:<port>` — never via the `_site` folder path directly. |
| **EC-PS5-COMPAT** | PowerShell 5.1 in VS Developer Shell | VS 2026 Developer Shell runs PS 5.1, not PS 7. Scripts must not use `#Requires -Version 7.2`, `$using:` in `Start-Job`, ternary `? :`, null-coalescing `??=`, or `[List]::new()`. Use `New-Object`, `-ArgumentList`, and `if/else` blocks. |
