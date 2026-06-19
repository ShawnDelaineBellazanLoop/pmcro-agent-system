# MAF / Colony Law Reference

> **Maintained by:** skill-maker-agent
> **Read this file when a Colony Law violation is suspected during provisioning.**

This is the canonical enumeration of laws that every generated skill package must
satisfy before it can be marked `DISPOSITION: COMPLETE` and appended to `S:\registry.yaml`.
Laws here are enforced by skill-maker-agent at Checker time during provisioning; they
are distinct from runtime Colony Laws enforced by orchestrator-agent during execution.

---

## Provisioning-Time Laws (enforced by skill-maker-agent)

| ID | Law | Rule | Violation Signal |
|:---|:----|:-----|:------------------|
| `EC-SYS-001` | Atomic Content Protocol | Every output is a complete file — no snippets, no `TODO`, no placeholders. | Any `{{token}}` left unsubstituted in a non-template file, or a file under a stated size threshold with truncated content. |
| `EC-SYS-002` | Minimalist Planning | One file per PMCR-O cycle. No batching. | Two or more `write_file` calls reported under a single cycle number. |
| `GTDDD-MANDATE` | Token Hygiene | Zero hardcoded company data in templates/assets. All specifics use `{{tokens}}`. | A literal company name, path, or brand value appears in `assets/skill_template.md` or `assets/domain_config_template.json`. |
| `MAF-NATIVE` | MAF Native Hierarchy | Every package has the canonical 6-item layout: `SKILL.md`, `domain_config.json`, `scripts/`, `references/`, `assets/`, `evals/`, `logs/`. | `directory_tree` on the package root is missing any of the 7 entries (6 subdirs + 2 files). |
| `MAF-FRONTMATTER` | Frontmatter Completeness | Every `SKILL.md` carries `metadata.version`, `metadata.tier`, `metadata.capability_class`, `metadata.maf.triangle_role`, `metadata.maf.kernel_plugin`, `metadata.maf.kernel_function`. | Any required key absent from the YAML frontmatter block. |
| `MAF-CLASS-UNIQUE` | Capability Class Uniqueness | New agent's `capability_class` does not collide with a reserved PHASE class (see `capability_classes.md`). | Proposed class matches `LOOP_CONTROLLER`, `STRATEGY_GENERATION`, `EXECUTION_ENGINE`, `VALIDATION_GATE`, or `TERMINAL_ARBITRATION` for a non-phase agent. |
| `REGISTRY-SEAL` | Registry Sealing | Package is not COMPLETE until its entry exists in `S:\registry.yaml` under `skills:` and in `load_order:`. | `registry.yaml` lacks a `skills.<agent-name>` block after final file write. |

---

## Runtime Laws Referenced During Provisioning (informational — owned by orchestrator-agent)

These are not enforced by skill-maker-agent, but a newly provisioned agent's `SKILL.md`
must not contradict them:

| ID | Law |
|:---|:----|
| `EC-002` | TYPE 1 (mutative) tool calls are Orchestrator-dispatch only. |
| `EC-004` | TYPE 2 (read-only) tool calls may be invoked directly by Phase/Subject agents. |
| `EC-009` | Every loop cycle writes a TrailFrame before terminating. |
| `ARCH-NEW-001` | TYPE 1 vs TYPE 2 MCP split is immutable once ratified. |
| `ARCH-NEW-002` | Single `AgentService` architecture — no per-phase gRPC services. |

If a new agent's domain actions are mutative (writes, deletes, network calls with side
effects), its `domain_config.json` actions must be tagged so the Orchestrator can route
them as TYPE 1 per `EC-002`. Read-only domain actions (`mk_*` reads, `get_*`, `list_*`)
may be tagged TYPE 2.

---

## Violation Handling Procedure

1. **[C] Checker phase detects violation** → halt the current cycle, do not write the file.
2. **Report which law ID was violated** and the specific signal observed.
3. **Re-plan** the cycle with the violation corrected.
4. **Re-attempt** the single file write. Do not proceed to the next cycle until clean.
5. If three consecutive attempts fail the same law, **escalate to the Reflector** for a
   terminal disposition rather than looping indefinitely.

---

## Colony Law vs. Provisioning Law — Disambiguation

- **Colony Laws** (`EC-*` codes in `colony-laws.md`) govern the *running* PMCR-O loop —
  they apply to orchestrator-agent, planner-agent, maker-agent, checker-agent,
  reflector-agent during live execution.
- **Provisioning-Time Laws** (this file) govern *skill-maker-agent's own output* when it
  is scaffolding a new package. They are a subset/specialization, not a separate
  authority — skill-maker-agent never overrides a runtime Colony Law.
