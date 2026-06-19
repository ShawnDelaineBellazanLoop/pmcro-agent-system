# Custom Template & Branding Reference

> DocFX 2.78.5 | Modern Template | Validated 2026-06-19

## Built-in Template Stack

Always declare the template array in `docfx.json` as a stack — later entries override earlier ones:

```json
"template": ["default", "modern", "my-template"]
```

- `default` — required base
- `modern` — recommended overlay (dark mode, responsive, full-featured)
- `my-template` — your corporate branding layer (CSS/JS overrides only)

## Corporate Branding Overlay

Create a `my-template/` folder alongside `docfx.json`. DocFX merges it on top of `modern`.

### Directory Structure

```
docs/
├── docfx.json
└── my-template/
    ├── public/
    │   ├── main.css     ← style overrides
    │   └── main.js      ← behavior overrides
    └── partials/        ← optional: Mustache partial overrides
        └── head.tmpl.partial
```

### my-template/public/main.css — Corporate Branding

```css
/* {{company}} DocFX Branding Override */
/* Loaded after modern template CSS — use specificity or :root vars to override */

:root {
  /* Primary brand color */
  --bs-primary: {{brand-primary-hex}};
  --bs-primary-rgb: {{brand-primary-rgb}};

  /* Navbar */
  --docfx-navbar-bg: {{navbar-bg-hex}};
  --docfx-navbar-text: {{navbar-text-hex}};

  /* Code blocks */
  --docfx-code-font: 'Cascadia Code', 'JetBrains Mono', 'Fira Code', monospace;

  /* Typography */
  --docfx-body-font: '{{body-font}}', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
}

/* Header / navbar branding */
.navbar {
  background-color: var(--docfx-navbar-bg) !important;
  border-bottom: 3px solid {{brand-accent-hex}};
}

.navbar-brand img {
  height: 32px;
}

/* Article headings */
article h1 {
  color: {{brand-primary-hex}};
  border-bottom: 2px solid {{brand-accent-hex}};
  padding-bottom: 0.5rem;
}

/* API member rows — zebra striping */
.table-striped > tbody > tr:nth-of-type(odd) > * {
  background-color: rgba({{brand-primary-rgb}}, 0.04);
}

/* TOC active item */
.toc .nav-item.active > a {
  color: {{brand-primary-hex}};
  font-weight: 600;
  border-left: 3px solid {{brand-primary-hex}};
}

/* Footer */
footer {
  background-color: {{footer-bg-hex}};
  color: {{footer-text-hex}};
  padding: 2rem 0;
}

/* Code syntax highlight override — pair with highlight.js theme */
.hljs {
  border-radius: 6px;
}
```

### my-template/public/main.js — Behavior Overrides

```javascript
// {{company}} DocFX JavaScript Override
// Executed after modern template JS — do not redefine docfx globals

export default {
  start() {
    // Example: inject corporate analytics
    this._injectAnalytics();

    // Example: add version selector to navbar
    this._initVersionSelector();
  },

  _injectAnalytics() {
    // Replace with your analytics provider tag
    const script = document.createElement('script');
    script.async = true;
    script.src = 'https://{{analytics-provider}}/tag/{{analytics-id}}';
    document.head.appendChild(script);
  },

  _initVersionSelector() {
    // Reads version list from /versions.json — generate this as a build artifact
    fetch('/versions.json')
      .then(r => r.ok ? r.json() : null)
      .then(versions => {
        if (!versions) return;
        const select = document.createElement('select');
        select.className = 'form-select form-select-sm ms-2';
        select.style.width = 'auto';
        versions.forEach(v => {
          const opt = document.createElement('option');
          opt.value = v.url;
          opt.textContent = v.label;
          opt.selected = v.current;
          select.appendChild(opt);
        });
        select.addEventListener('change', () => window.location.href = select.value);
        document.querySelector('.navbar-nav')?.appendChild(select);
      })
      .catch(() => {});
  }
};
```

## Predefined Metadata Keys (modern template)

| Key | Effect |
|:----|:-------|
| `_appTitle` | Browser tab title suffix |
| `_appFooter` | Footer content (HTML supported) |
| `_appFaviconPath` | Path to favicon (relative to root) |
| `_appLogoPath` | Path to navbar logo image |
| `_appLogoUrl` | URL for the logo link |
| `_enableSearch` | `true`/`false` — client-side full-text search |
| `_disableContribution` | `true` to hide "Edit this page" |
| `_gitContribute` | `{ repo, branch, path }` object for edit links |
| `_gitUrlPattern` | Override git URL pattern for self-hosted GitLab/Bitbucket |
| `_noindex` | `true` to set `noindex` robots meta tag |
| `_disableNavbar` | `true` to hide the top navbar |
| `_disableBreadcrumb` | `true` to hide breadcrumbs |
| `_disableToc` | `true` to hide the TOC sidebar |
| `_disableAffix` | `true` to hide the in-page TOC affix |

## docfx.json Template Section

```json
{
  "build": {
    "template": ["default", "modern", "my-template"],
    "globalMetadata": {
      "_appTitle": "{{company}} Docs",
      "_appLogoPath": "images/logo.svg",
      "_appLogoUrl": "https://{{company-website}}",
      "_appFaviconPath": "images/favicon.ico",
      "_enableSearch": true,
      "_disableContribution": false,
      "_gitContribute": {
        "repo": "https://github.com/{{org}}/{{repo}}",
        "branch": "main",
        "path": "docs"
      }
    }
  }
}
```
