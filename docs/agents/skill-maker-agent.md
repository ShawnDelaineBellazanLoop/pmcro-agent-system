---
title: Skill Maker Agent
uid: agents.skill-maker-agent
---

# skill-maker-agent

**Type:** SUPPORT · **Tier:** ORCHESTRATION · **Capability:** RECURSIVE_PROVISIONER

Recursive Architecture Provisioner for the {{company}} Colony. Scaffolds new, high-fidelity PMCR-O agent skill packages on the DevDrive (S:\). The only agent authorized to extend the Colony's own registry.

---

## Responsibilities

- **Package provisioning** — scaffolds the full 6-directory MAF skill package hierarchy
- **Registry extension** — appends new agent entries to `S:\registry.yaml` via `mk_registry_entry`
- **Law enforcement** — all provisioned files honor EC-SYS-001, EC-SYS-002, GTDDD-MANDATE
- **Version validation** — references `maf_versions.md` before generating any version-bearing file

---

## Package Structure Provisioned

```
S:\skills\<new-agent>\
├── SKILL.md
├── domain_config.json
├── references\
│   └── versions.md
├── scripts\
├── evals\
│   └── smoke_test.md
└── assets\
```

---

## Domain Actions (mk_ vocabulary)

| Action | Output |
|:-------|:-------|
| `mk_dir_structure` | 6-directory hierarchy |
| `mk_skill_md` | SKILL.md with MAF frontmatter |
| `mk_domain_json` | domain_config.json with typed actions |
| `mk_reference` | Reference doc in references/ |
| `mk_script` | Executable script in scripts/ |
| `mk_eval` | Evaluation suite in evals/ |
| `mk_asset` | Asset/template in assets/ |
| `mk_registry_entry` | Appends to S:\registry.yaml |

---

## Invocation

```
/skill-maker-agent <provisioning intent>
```

Example:
```
/skill-maker-agent create a new playwright-agent for browser automation
```

---

## Validated MAF Versions

See `S:\skills\skill-maker-agent\references\maf_versions.md` for the live-validated package version table (validated 2026-06-19).

---

## SKILL.md Location

`S:\skills\skill-maker-agent\SKILL.md`
