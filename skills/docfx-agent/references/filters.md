# API Filter Configuration Reference

> DocFX 2.78.5 | filterConfig.yml | Validated 2026-06-19  
> Source: dotnet.github.io/docfx/docs/dotnet-api-docs.html

## Overview

`filterConfig.yml` controls which namespaces, types, and members appear in the generated API docs.
Reference it from `docfx.json` via `metadata[].filter: "filterConfig.yml"`.

## Default Filter Behavior

Without a filter file, DocFX only generates documentation for `public` and `protected` members.
Internal, private, and compiler-generated members are excluded by default.

## Enterprise filterConfig.yml Template

```yaml
# filterConfig.yml — {{company}} API Visibility Rules
# DocFX 2.78.5 — apiRules applied top-to-bottom; first match wins

apiRules:
  # ── Exclusions ────────────────────────────────────────────────────────────────

  # Exclude compiler-generated types
  - exclude:
      hasAttribute:
        uid: System.Runtime.CompilerServices.CompilerGeneratedAttribute

  # Exclude types marked with [EditorBrowsable(Never)]
  - exclude:
      hasAttribute:
        uid: System.ComponentModel.EditorBrowsableAttribute
        ctorArguments:
          - System.ComponentModel.EditorBrowsableState.Never

  # Exclude test namespaces
  - exclude:
      uidRegex: '^{{company}}\..*\.Tests($|\..*)'
      type: Namespace

  # Exclude internal implementation namespaces
  - exclude:
      uidRegex: '^{{company}}\.Internal($|\..*)'
      type: Namespace

  # Exclude obsolete members (optional — remove to keep deprecated APIs visible)
  # - exclude:
  #     hasAttribute:
  #       uid: System.ObsoleteAttribute

  # ── Inclusions ────────────────────────────────────────────────────────────────

  # Include all public types in {{company}} namespaces
  - include:
      uidRegex: '^{{company}}\.'
      type: Type

  # Include public and protected members
  - include:
      type: Member
      kind:
        - Property
        - Method
        - Event
        - Field

  # ── Default fallback ──────────────────────────────────────────────────────────
  # Exclude everything not explicitly matched above
  - exclude:
      type: '*'
```

## Rule Structure

Each rule has either `include` or `exclude` as its key, with these optional matchers:

| Matcher | Type | Description |
|:--------|:-----|:------------|
| `uidRegex` | string | Regex matched against the full UID (namespace + type + member) |
| `type` | string \| `*` | `Namespace`, `Type`, `Member`, or `*` (all) |
| `kind` | string[] | For `type: Member` — `Property`, `Method`, `Event`, `Field`, `Constructor` |
| `hasAttribute` | object | Match types/members bearing a specific attribute |

## Common Patterns

### Exclude a specific namespace

```yaml
- exclude:
    uidRegex: '^Acme\.Internal($|\..*)'
    type: Namespace
```

### Include only public methods (exclude properties, fields, events)

```yaml
- include:
    type: Member
    kind: [Method]
- exclude:
    type: Member
    kind: [Property, Field, Event, Constructor]
```

### Exclude compiler-generated backing fields

```yaml
- exclude:
    hasAttribute:
      uid: System.Runtime.CompilerServices.CompilerGeneratedAttribute
```

### Include internal members for internal documentation site

```yaml
# Remove the default public-only filter
# Set --disableDefaultFilter in docfx.json properties or CLI:
# "disableDefaultFilter": true in metadata section
- include:
    type: '*'
```

### docfx.json integration

```json
{
  "metadata": [
    {
      "src": [{"files": ["**/*.csproj"], "src": "../src"}],
      "dest": "api",
      "filter": "filterConfig.yml",
      "allowCompilationErrors": false
    }
  ]
}
```

### Disable default filter to include internal APIs

Set in `metadata` section:

```json
{
  "metadata": [
    {
      "src": [...],
      "dest": "api",
      "filter": "filterConfig.yml",
      "includePrivateMembers": true
    }
  ]
}
```

Or via CLI: `docfx metadata --disableDefaultFilter`

## Rule Evaluation Order

Rules are evaluated **top to bottom**. The **first matching rule wins**.
Place most-specific rules before broad catch-alls.

```
Example evaluation for Acme.Internal.Cache.MemoryCache:
1. Check: matches '^Acme\.Internal' → YES → EXCLUDE ✓ (stops here)
2. Subsequent rules are not evaluated for this UID.
```
