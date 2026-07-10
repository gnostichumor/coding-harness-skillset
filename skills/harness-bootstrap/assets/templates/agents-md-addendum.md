<!-- Append to AGENTS.md, AFTER any bd-managed BEGIN BEADS / END BEADS
     marker blocks (never edit inside those markers). This is the
     condensed, cross-tool-portable version of CLAUDE.md's addendum --
     keep it short; point to docs/ for depth rather than duplicating it
     at length. Fill every {{TOKEN}}, then delete every HTML comment in
     this template (including this one) before committing. -->

## Project Context: {{PROJECT_NAME}}

**Status:** pre-implementation (or: state honestly if scaffolding already
landed). Only `docs/` and this harness scaffolding exist unless noted
otherwise. `bd ready` always points at what's next.

- **Product requirements:** {{PRD_PATH}}
- **Implementation decisions:** `docs/architecture.md`
- **Quality bar / Definition of Done:** `docs/quality-standards.md`
- **Decision log (chronological, with rationale):** `DECISIONS.md`

**One-paragraph summary:** {{ONE_PARAGRAPH_ARCHITECTURE_SUMMARY}}

**Planned verification commands** (once scaffolding lands — see
`docs/quality-standards.md`): {{VERIFICATION_COMMANDS_INLINE}}

**WIP=1:** only one bd issue may be `in_progress` at a time, enforced by
`.claude/hooks/bd-wip-gate.sh` — a `bd update --claim` on a second issue
is denied while one is already claimed. Close or unclaim first.
