# DocFX Agent — Evaluation Suite (Smoke Tests)

> **Agent:** docfx-agent v1.0.0  
> **Colony Law Observed:** EC-SYS-001, EC-SYS-002, GTDDD-MANDATE  
> **Validated Versions:** DocFX 2.78.5 / Docfx.App 2.78.5 / .NET 9 SDK  
> **Maintained by:** skill-maker-agent  

---

## Purpose

This file defines the acceptance criteria and sample test cases used to verify the
docfx-agent produces correct, production-ready, enterprise-grade outputs. Run these
evals after any update to SKILL.md, domain_config.json, or any reference file.

---

## Eval 1 — Intent Routing

**Objective:** Verify the agent correctly maps user intent to the right reference and domain action.

| # | User Input | Expected Action | Expected Reference |
|:--|:-----------|:----------------|:-------------------|
| 1.1 | "Set up DocFX for my .NET 9 solution" | `mk_scaffold` | `docfx_json_reference.md` |
| 1.2 | "Generate a GitHub Actions workflow to build and deploy my docs" | `mk_cicd_pipeline` | `cicd_patterns.md` |
| 1.3 | "I want to exclude internal types from the API docs" | `mk_filter_yml` | `filters.md` |
| 1.4 | "Add our company logo and primary brand color to the docs" | `mk_template` | `templates.md` |
| 1.5 | "Build the docs programmatically from a C# application" | `mk_sdk_integration` | `api_sdk.md` |
| 1.6 | "Configure cross-references to link to Microsoft BCL types" | `mk_xref_config` | `docfx_json_reference.md` |
| 1.7 | "Generate a PDF version of our API docs" | `mk_pdf_config` | `docfx_json_reference.md` |
| 1.8 | "We have 3 separate projects in a monorepo, doc them all" | `mk_monorepo_config` | `docfx_json_reference.md` |
| 1.9 | "Pin the docfx version so all devs use the same one" | `mk_dotnet_tool_manifest` | `versions.md` |

**Pass Criteria:** Agent correctly identifies action and reference file without hallucinating alternate approaches.

---

## Eval 2 — Version Pinning

**Objective:** All generated outputs must reference validated versions exactly.

| # | Artefact | Field | Expected Value | Fail Condition |
|:--|:---------|:------|:---------------|:---------------|
| 2.1 | `.config/dotnet-tools.json` | `"version"` | `"2.78.5"` | Any other version |
| 2.2 | `*.csproj` | `<PackageReference Include="Docfx.App">` | `Version="2.78.5"` | Version mismatch |
| 2.3 | `*.csproj` | `Microsoft.CodeAnalysis.Workspaces.MSBuild` | `Version="4.10.0"` | Any other version |
| 2.4 | `*.csproj` | `<TargetFramework>` | `net9.0` or `net8.0` | `net6.0`, `net7.0` |
| 2.5 | GitHub Actions YAML | `dotnet-version` | `'9.0.x'` or `'8.0.x'` | `'6.0.x'`, `'7.0.x'` |
| 2.6 | GitHub Actions YAML | `node-version` (if present) | `'24.x'` | Any older LTS |

**Pass Criteria:** Zero version deviations from `references/versions.md`.

---

## Eval 3 — Token Hygiene (GTDDD-MANDATE)

**Objective:** Verify no hardcoded company, org, or project data appears in template outputs.

| # | Artefact | Forbidden Pattern | Required Pattern |
|:--|:---------|:------------------|:-----------------|
| 3.1 | `docfx.json` | Any real company name | `{{company}}` |
| 3.2 | `docfx.json` | Any real GitHub org/repo | `{{org}}`, `{{repo}}` |
| 3.3 | `docfx.json` | Any real domain/URL | `{{base-url}}` |
| 3.4 | `filterConfig.yml` | Any real namespace | `{{company}}` prefix pattern |
| 3.5 | GitHub Actions YAML | Any real branch name other than `main` | Parameterised or `main` default |
| 3.6 | `SKILL.md` / templates | Literal year values | `{{year}}` token |

**Pass Criteria:** `grep -r "Contoso\|Fabrikam\|Northwind\|MyCompany"` finds zero matches in generated files.

---

## Eval 4 — docfx.json Structural Completeness (EC-SYS-001)

**Objective:** Every generated `docfx.json` includes all required enterprise sections.

| # | Section | Required Keys | Pass Condition |
|:--|:--------|:--------------|:---------------|
| 4.1 | `metadata[]` | `src[].files`, `src[].exclude`, `src[].src`, `dest`, `filter`, `properties.TargetFramework` | All present |
| 4.2 | `build` | `content`, `resource`, `output`, `template`, `globalMetadata` | All present |
| 4.3 | `build.globalMetadata` | `_appTitle`, `_enableSearch`, `_gitContribute` | All present |
| 4.4 | `build.template` | Array containing both `"default"` and `"modern"` | Both entries present |
| 4.5 | `build.xref` | Microsoft Docs xref URL | `xref.docs.microsoft.com` present |
| 4.6 | `build` | `warningsAsErrors: true` | Explicitly set |
| 4.7 | `build.sitemap` | `baseUrl` | Token present |

**Pass Criteria:** Agent-generated `docfx.json` passes `validate.ps1 Check 1/4` with no JSON errors.

---

## Eval 5 — CI/CD Pipeline Quality

**Objective:** Generated pipelines are production-ready with caching and zero manual steps.

| # | Feature | GitHub Actions | Azure Pipelines |
|:--|:--------|:---------------|:----------------|
| 5.1 | Trigger on `main` push | `push: branches: [main]` | `trigger: [main]` |
| 5.2 | PR validation | `pull_request:` trigger | `pr:` trigger |
| 5.3 | NuGet/tool caching | `actions/cache` with correct key | `Cache@2` task |
| 5.4 | `dotnet tool restore` | Present before docfx invocation | Present before task |
| 5.5 | `warningsAsErrors` | `--warningsAsErrors` flag | Same |
| 5.6 | Deployment gated on build | `needs: build` or sequential jobs | `dependsOn:` |
| 5.7 | Correct permissions | `contents: read`, `pages: write`, `id-token: write` | Equivalent |

**Pass Criteria:** Pipeline YAML is syntactically valid (`yamllint`) and includes all 7 features.

---

## Eval 6 — Script Functionality

**Objective:** PowerShell scripts in `scripts/` execute without errors on Windows Server 2022+ / PS 7.2+.

| # | Script | Test Command | Expected Exit Code |
|:--|:-------|:-------------|:-------------------|
| 6.1 | `build.ps1` | `.\scripts\build.ps1 -DocfxRoot ./docs -WarningsAsErrors` | `0` on clean build |
| 6.2 | `build.ps1` | Run with missing `docfx.json` | `1` (pre-flight fail) |
| 6.3 | `serve.ps1` | `.\scripts\serve.ps1 -SkipMetadata` | Server starts on 8080 |
| 6.4 | `validate.ps1` | `.\scripts\validate.ps1 -DocfxRoot ./docs -SkipBuild` | `0` on valid config |
| 6.5 | `validate.ps1` | Run against malformed `docfx.json` | `1` (JSON parse error) |
| 6.6 | `validate.ps1` | Run with `--warningsAsErrors` on repo with xref errors | `1` (non-zero exit) |

---

## Eval 7 — Atomic Content Protocol (EC-SYS-001)

**Objective:** No generated file contains stubs, TODOs, or placeholder comments.

Forbidden patterns in any agent output:
```
# TODO
# FIXME
# placeholder
<!-- TODO -->
throw new NotImplementedException()
/* ... */
[your content here]
```

**Pass Criteria:** `grep -riP "TODO|FIXME|placeholder|NotImplementedException" <generated-file>` returns zero matches.

---

## Eval Scorecard

| Eval | Category | Weight | Status |
|:-----|:---------|:-------|:-------|
| 1 | Intent routing | 20% | ⬜ Pending |
| 2 | Version pinning | 20% | ⬜ Pending |
| 3 | Token hygiene | 15% | ⬜ Pending |
| 4 | Config completeness | 20% | ⬜ Pending |
| 5 | CI/CD quality | 10% | ⬜ Pending |
| 6 | Script functionality | 10% | ⬜ Pending |
| 7 | Atomic content | 5% | ⬜ Pending |

**Threshold to pass:** ≥ 90% weighted score (all Eval 2 and 7 checks must be green — no partial credit).
