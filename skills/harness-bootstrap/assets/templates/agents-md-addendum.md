<!-- Append to AGENTS.md, AFTER whatever `br agents --add --force` wrote
     (inspect the file first -- br manages its own beads-workflow section;
     don't edit inside anything that looks generated, append below it
     instead). This is the condensed, cross-tool-portable version of
     CLAUDE.md's addendum -- keep it short; point to docs/ for depth
     rather than duplicating it at length. Brownfield: if AGENTS.md
     already has real project-specific content beyond what `br agents`
     wrote, append this as a new section rather than replacing anything.
     Fill every {{TOKEN}}, then delete every HTML comment in this
     template (including this one) before committing. -->

## Project Context: {{PROJECT_NAME}}

**Status:** pre-implementation (or: state honestly if scaffolding already
landed / this is a brownfield repo with existing code). Only `docs/` and
this harness scaffolding exist unless noted otherwise. `br ready` always
points at what's next.

- **Product requirements:** {{PRD_PATH}}
- **Implementation decisions:** `docs/architecture.md`
- **Quality bar / Definition of Done:** `docs/quality-standards.md`
- **Decision log (chronological, with rationale):** `DECISIONS.md`

**One-paragraph summary:** {{ONE_PARAGRAPH_ARCHITECTURE_SUMMARY}}

**Planned verification commands** (once scaffolding lands — see
`docs/quality-standards.md`): {{VERIFICATION_COMMANDS_INLINE}}

**WIP=1:** only one br issue may be `in_progress` at a time, enforced
natively by `br` via the `.beads/policy.yaml` capacity cap (`in_progress`
hard-limited to 1) — a `br update --claim` on a second issue is rejected
while one is already claimed. Close or unclaim first.
