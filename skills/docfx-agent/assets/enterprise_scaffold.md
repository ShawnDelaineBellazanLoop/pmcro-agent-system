# Enterprise DocFX Scaffold — Production Quick Start

This asset contains the minimum complete set of files to bootstrap a production DocFX site.
Apply {{token}} substitutions before writing to disk.

---

## File: .config/dotnet-tools.json

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

---

## File: docs/docfx.json

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
      "namespaceLayout": "nested",
      "disableGitFeatures": false
    }
  ],
  "build": {
    "content": [
      { "files": ["**/*.{md,yml}"], "exclude": ["_site/**", "obj/**"] }
    ],
    "resource": [
      { "files": ["**/media/**", "**/images/**"] }
    ],
    "output": "_site",
    "template": ["default", "modern"],
    "globalMetadata": {
      "_appTitle": "{{company}} Developer Docs",
      "_appFooter": "© {{year}} {{company}}",
      "_enableSearch": true,
      "_disableContribution": false,
      "_gitContribute": {
        "repo": "https://github.com/{{org}}/{{repo}}",
        "branch": "main",
        "path": "docs"
      }
    },
    "sitemap": {
      "baseUrl": "https://{{base-url}}",
      "priority": 0.5,
      "changefreq": "weekly"
    },
    "xref": ["https://xref.docs.microsoft.com/query?uid={uid}"],
    "warningsAsErrors": true
  }
}
```

---

## File: docs/filterConfig.yml

```yaml
apiRules:
  - exclude:
      hasAttribute:
        uid: System.Runtime.CompilerServices.CompilerGeneratedAttribute
  - exclude:
      hasAttribute:
        uid: System.ComponentModel.EditorBrowsableAttribute
        ctorArguments:
          - System.ComponentModel.EditorBrowsableState.Never
  - exclude:
      uidRegex: '^{{company}}\..*\.Tests($|\..*)'
      type: Namespace
  - include:
      uidRegex: '^{{company}}\.'
      type: Type
  - include:
      type: Member
      kind: [Property, Method, Event, Field, Constructor]
  - exclude:
      type: '*'
```

---

## File: docs/toc.yml

```yaml
- name: Home
  href: index.md
- name: Articles
  href: articles/
- name: API Reference
  href: api/
```

---

## File: docs/index.md

```markdown
---
_appTitle: "{{company}} Developer Docs"
---

# Welcome to {{company}} Developer Documentation

{{description}}

## Getting Started

- [Installation Guide](articles/getting-started.md)
- [API Reference](api/index.md)

## Resources

- [Changelog](articles/changelog.md)
- [Contributing](articles/contributing.md)
```

---

## File: docs/articles/toc.yml

```yaml
- name: Getting Started
  href: getting-started.md
- name: Changelog
  href: changelog.md
```

---

## File: docs/.gitignore

```
_site/
api/
obj/
```
