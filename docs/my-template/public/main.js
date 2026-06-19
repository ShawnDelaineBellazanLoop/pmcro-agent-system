// Tooensure Colony — PMCR-O Documentation
// main.js v3.0 — "Ledger" direction
// DocFX modern template JS override

export default {
  // Lock to dark by default. User toggle still works via DocFX's built-in theme switcher.
  defaultTheme: 'dark',

  // GitHub icon in navbar
  iconLinks: [
    {
      icon: 'github',
      href: 'https://github.com',
      title: 'GitHub'
    }
  ],

  start() {
    this._addCopyButtons();
    this._externalLinksNewTab();
    this._addLedgerRowNumbers();
    this._highlightCurrentSection();
  },

  // Copy button on all code blocks — styled to Ledger tokens
  _addCopyButtons() {
    document.querySelectorAll('pre > code').forEach((codeBlock) => {
      const pre = codeBlock.parentElement;
      if (pre.querySelector('.pmcro-copy-btn')) return;
      pre.style.position = 'relative';

      const button = document.createElement('button');
      button.type = 'button';
      button.className = 'pmcro-copy-btn';
      button.textContent = 'Copy';
      button.setAttribute('aria-label', 'Copy code to clipboard');

      pre.addEventListener('mouseenter', () => button.classList.add('visible'));
      pre.addEventListener('mouseleave', () => button.classList.remove('visible'));

      button.addEventListener('click', async () => {
        try {
          await navigator.clipboard.writeText(codeBlock.innerText.trim());
          button.textContent = '✓ Copied';
          button.classList.add('success');
          setTimeout(() => {
            button.textContent = 'Copy';
            button.classList.remove('success');
          }, 1600);
        } catch {
          button.textContent = 'Failed';
          setTimeout(() => { button.textContent = 'Copy'; }, 1600);
        }
      });

      pre.appendChild(button);
    });
  },

  // Open external links in new tab
  _externalLinksNewTab() {
    const host = window.location.hostname;
    document.querySelectorAll('article a[href^="http"]').forEach((a) => {
      try {
        const url = new URL(a.href);
        if (url.hostname !== host) {
          a.setAttribute('target', '_blank');
          a.setAttribute('rel', 'noopener noreferrer');
        }
      } catch { /* ignore */ }
    });
  },

  // Stamp first-column cells in law/agent tables with a ledger-mark data attr
  // so CSS can target them without a class on every <td>
  _addLedgerRowNumbers() {
    document.querySelectorAll('article table').forEach((table) => {
      table.querySelectorAll('tbody tr').forEach((tr) => {
        const firstCell = tr.querySelector('td:first-child');
        if (firstCell) firstCell.setAttribute('data-ledger', 'true');
      });
    });
  },

  // Highlight the TOC entry matching the section currently in view
  _highlightCurrentSection() {
    const headings = Array.from(document.querySelectorAll('article h2, article h3'));
    if (!headings.length) return;

    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        const id = entry.target.id;
        document.querySelectorAll('.toc .nav-link').forEach((link) => {
          link.classList.toggle('toc-active-scroll',
            link.getAttribute('href') === `#${id}`);
        });
      });
    }, { rootMargin: '-20% 0px -70% 0px', threshold: 0 });

    headings.forEach((h) => observer.observe(h));
  }
};
