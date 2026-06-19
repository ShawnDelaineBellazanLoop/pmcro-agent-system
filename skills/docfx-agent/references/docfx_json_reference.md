# docfx.json Enterprise Configuration Reference

> DocFX 2.78.5 | Validated 2026-06-19 | Source: dotnet.github.io/docfx/reference/docfx-json-reference.html

## Enterprise-Grade docfx.json (Full Template)

```json
{
  "metadata": [
    {
      "src": [
        {
          "files": ["**/*.csproj"],
          "exclude": ["**/bin/**", "**/obj/**", "**/*.Tests.csproj"],
          "src": "../src"
        }
      ],
      "dest": "api",
      "filter": "filterConfig.yml",
      "properties": {
        "Configuration": "Release",
        "TargetFramework": "net9.0"
      },
      "disableGitFeatures": false,
      "namespaceLayout": "nested"
    }
  ],
  "build": {
    "content": [
      {
        "files": ["**/*.{md,yml}"],
        "exclude": ["_site/**"]
      }
    ],
    "resource": [
      {
        "files": ["**/media/**", "**/images/**"]
      }
    ],
    "output": "_site",
    "template": ["default", "modern"],
    "globalMetadata": {
      "_appTitle": "{{company}} Developer Documentation",
      "_appFooter": "© {{year}} {{company}}. All rights reserved.",
      "_enableSearch": true,
      "_disableContribution": false,
      "_gitContribute": {
        "repo": "https://github.com/{{org}}/{{repo}}",
        "branch": "main",
        "path": "docs"
      }
    },
    "fileMetadata": {
      "_appTitle": {
        "articles/api-guide/**/*.md": "{{company}} API Guide",
        "articles/architecture/**/*.md": "{{company}} Architecture"
      }
    },
    "sitemap": {
      "baseUrl": "https://{{base-url}}",
      "priority": 0.5,
      "changefreq": "weekly"
    },
    "xref": [
      "https://xref.docs.microsoft.com/query?uid={uid}"
    ],
    "logLevel": "Warning",
    "warningsAsErrors": true
  }
}
```

## Minimal Scaffold (Quick Start)

```json
{
  "metadata": [
    {
      "src": [
        {
          "files": ["**/*.csproj"],
          "exclude": ["**/bin/**", "**/obj/**"],
          "src": "../src"
        }
      ],
      "dest": "api"
    }
  ],
  "build": {
    "content": [{"files": ["**/*.{md,yml}"]}],
    "resource": [{"files": ["**/media/**"]}],
    "output": "_site",
    "template": ["default", "modern"],
    "globalMetadata": {
      "_appTitle": "{{project-title}}"
    }
  }
}
```

## Key Configuration Sections

### metadata[]
Controls the `docfx metadata` phase — extracting API docs from source code.

| Field | Type | Description |
|:------|:-----|:------------|
| `src[].files` | glob[] | Glob patterns for .csproj, .sln, .slnx, .dll, or .cs files |
| `src[].exclude` | glob[] | Exclusion patterns (always exclude bin/obj) |
| `src[].src` | string | Root path relative to docfx.json |
| `dest` | string | Output folder for generated YAML (e.g. `"api"`) |
| `filter` | string | Path to `filterConfig.yml` |
| `properties` | object | MSBuild properties — always set `TargetFramework` and `Configuration` |
| `namespaceLayout` | `"flattened"` \| `"nested"` | TOC layout: `nested` preferred for large projects |
| `disableGitFeatures` | bool | Set `true` in CI if git history is shallow (speeds up build) |
| `noRestore` | bool | Skip `dotnet restore` — only use if dependencies are pre-restored |

### build.content[]
Specifies which Markdown and YAML files to include in the site build.

### build.globalMetadata
Metadata applied to every page. Key predefined keys:

| Key | Effect |
|:----|:-------|
| `_appTitle` | Browser tab title suffix |
| `_appFooter` | Footer text |
| `_enableSearch` | Enable/disable client-side search |
| `_disableContribution` | Hide the "Edit this page" link |
| `_gitContribute` | Configures the "Edit on GitHub/GitLab" link |
| `_noindex` | Set `true` to add `<meta name="robots" content="noindex">` |

### build.fileMetadata
Override metadata for specific file globs. Key overrides `globalMetadata` for matched files.
YAML Front Matter overrides `fileMetadata` which overrides `globalMetadata`.

### build.template
Always use `["default", "modern"]` for the latest features.
To layer custom branding: `["default", "modern", "my-template"]`.

### build.xref
Cross-reference map URLs. The Microsoft Docs xref map enables linking to .NET BCL types:
```json
"xref": ["https://xref.docs.microsoft.com/query?uid={uid}"]
```

### build.sitemap
Generates `sitemap.xml` for search engine indexing. Set `baseUrl` to your canonical URL.

### build.warningsAsErrors
Set `true` in CI to enforce zero-warning builds. Broken xrefs and missing UIDs become errors.

## PDF Section (optional)

```json
{
  "pdf": {
    "content": [{"files": ["**/*.{md,yml}"]}],
    "resource": [{"files": ["**/media/**"]}],
    "output": "_pdf",
    "template": ["default", "pdf"],
    "globalMetadata": {
      "_appTitle": "{{company}} API Reference"
    },
    "pdfHeaderTemplate": "templates/pdf-header.html",
    "pdfFooterTemplate": "templates/pdf-footer.html"
  }
}
```

## Multi-Project / Monorepo

Add multiple entries to `metadata[]` — each with its own `src`, `dest`, and `filter`:

```json
{
  "metadata": [
    {
      "src": [{"files": ["**/*.csproj"], "src": "../src/Core"}],
      "dest": "api/core"
    },
    {
      "src": [{"files": ["**/*.csproj"], "src": "../src/Extensions"}],
      "dest": "api/extensions"
    }
  ]
}
```

## Scaffold Directory Structure

```
docs/
├── docfx.json              ← root config
├── filterConfig.yml        ← API visibility rules
├── toc.yml                 ← top-level navigation
├── index.md                ← landing page
├── articles/               ← conceptual/guide Markdown
│   └── toc.yml
├── api/                    ← auto-generated (docfx metadata output)
├── _site/                  ← build output (add to .gitignore)
└── templates/
    └── my-template/        ← custom template overrides
```

## .gitignore Additions

```
_site/
api/
obj/
.docfx/
```
