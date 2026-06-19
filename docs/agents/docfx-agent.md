---
title: DocFX Agent
description: Production-ready DocFX documentation automation agent — scaffold, build, serve, validate, and publish the Colony docs site.
uid: agents.docfx-agent
---

# docfx-agent

**Type:** SUBJECT · **Tier:** EXECUTION · **Capability:** DOCUMENTATION_AUTOMATION  
**Validated:** DocFX **2.78.5** (NuGet, 2026-02-24) · .NET 9/10 · MAF 1.7.0

Production-ready DocFX documentation automation agent for the Tooensure Colony. Handles the full documentation lifecycle: scaffold, build, serve, validate, and publish.

> [!NOTE]
> DocFX 2.78.5 is the current stable release as of 2026-02-24. It targets `.NET 8.0+` and runs on .NET 10 runtime.
> Node.js is not required for tool users — removed as a runtime dependency in 2.78.x.

---

## Validated Version Matrix

| Component | Pinned Version | Source | Status |
|:----------|:---------------|:-------|:-------|
| `docfx` CLI | **2.78.5** | NuGet `dotnet-tools.json` | ✅ Current |
| `Docfx.App` SDK | **2.78.5** | NuGet | ✅ Current |
| .NET SDK runtime | **9.0 / 10.0** | `net8.0`+ target | ✅ Compatible |
| Modern template | built-in | `["default","modern"]` | ✅ Recommended |
| Markdig extensions | Abbreviations, Footnotes, DefinitionLists | `markdownEngineProperties` | ✅ Configured |

---

## Domain Actions

| Action | Type | Description |
|:-------|:-----|:------------|
| `mk_scaffold` | TYPE1 | Create `docfx.json`, toc.yml, index.md, filterConfig.yml |
| `mk_build` | TYPE1 | Run `docfx build` with `-WarningsAsErrors` |
| `mk_serve` | TYPE2 | Start hot-reload dev server with browser auto-open |
| `mk_validate` | TYPE2 | Link-check, xref-check, JSON schema lint, dry-run |
| `mk_publish` | TYPE1 | Deploy `_site/` to GitHub Pages or Azure Static Web Apps |
| `mk_api_reference` | TYPE1 | Build API docs from XML doc comments in `src/**/*.csproj` |
| `mk_xref_config` | TYPE2 | Wire .NET + MAF xref maps into docfx.json |
| `mk_filter_yml` | TYPE2 | Author filterConfig.yml (include/exclude API rules) |
| `mk_toc` | TYPE2 | Author or update toc.yml navigation tree |
| `mk_docfx_json` | TYPE2 | Set globalMetadata, postProcessors, markdownEngineProperties |
| `mk_template` | TYPE2 | Generate `my-template/public/main.css` + `main.js` overrides |
| `mk_cicd_pipeline` | TYPE1 | Generate GitHub Actions or Azure Pipelines YAML |

---

## docfx.json Production Config

The Colony site uses the following production-grade `docfx.json` settings:

```json
{
  "build": {
    "globalMetadata": {
      "_appTitle":            "...",
      "_enableSearch":        true,
      "_appLogoPath":         "media/colony-logo.svg",
      "_gitRepoUrl":          "https://github.com/...",
      "_gitUrlPattern":       "auto"
    },
    "markdownEngineProperties": {
      "markdigExtensions": ["Abbreviations", "Footnotes", "DefinitionLists"]
    },
    "template": ["default", "modern", "my-template"],
    "postProcessors": ["ExtractSearchIndex"]
  }
}
```

Key points:
- `ExtractSearchIndex` must be explicit in `postProcessors` for reliable full-text search
- `_gitUrlPattern: "auto"` enables edit-on-GitHub links on every article
- `markdigExtensions` are additive to DocFX's own defaults

---

## Scripts

| Script | Purpose |
|:-------|:--------|
| `scripts/build.ps1` | Pre-flight → restore → build → optional `-Serve` |
| `scripts/validate.ps1` | 4 checks: link-check, xref-check, warningsAsErrors dry-run, JSON schema lint |
| `scripts/batch_package.py` | Archive all skill packages to `S:\backups\*.zip` (preserves empty dirs) |

```powershell
cd S:\docs

# Build + serve (hot reload)
.\scripts\build.ps1 -WarningsAsErrors -Serve

# Validate only
.\scripts\validate.ps1
```

---

## Template Customization

The site uses the **Ledger v3** design system (`my-template/public/main.css` + `main.js`):

- `defaultTheme: 'dark'` locked in `main.js` — dark mode always on, toggle preserved
- `color-scheme: dark` declared — browser chrome (scrollbars, form controls) matches
- 4-step elevation system: `--e0` canvas → `--e1` raised → `--e2` float → `--e3` overlay
- Semantic accents: `--seal` (brass) = ratified/immutable only · `--signal` (teal) = interactive only · `--alarm` (brick) = HALT/violation only
- Source Serif 4 display font on H1/H2; Inter body; JetBrains Mono for code/footer/breadcrumb

---

## References

| Reference | Path |
|:----------|:-----|
| Version pins | `S:\skills\docfx-agent\references\versions.md` |
| docfx.json patterns | `S:\skills\docfx-agent\references\docfx_json_reference.md` |
| CI/CD integration | `S:\skills\docfx-agent\references\cicd_patterns.md` |
| DocFX App SDK | `S:\skills\docfx-agent\references\api_sdk.md` |
| Template customization | `S:\skills\docfx-agent\references\templates.md` |
| Filter configuration | `S:\skills\docfx-agent\references\filters.md` |

---

## SKILL.md

`S:\skills\docfx-agent\SKILL.md`
