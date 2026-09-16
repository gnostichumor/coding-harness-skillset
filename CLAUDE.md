# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

This is a **skills repository** for "Learn Harness Engineering" — it contains no application code. It's a set of Claude Code Skills (`SKILL.md` files) that teach and apply the methodology of building production-grade agent harnesses, plus the lecture content those skills are derived from. Everything here is markdown, YAML frontmatter, and a handful of bash scripts bundled as skill assets.

There are no build, lint, or test commands — this project doesn't produce a running application. The closest thing to "verification" here is checking that generated documents (produced *by* the skills, in other repos) don't have leftover template placeholders — see `skills/harness-bootstrap/SKILL.md` step 9 for that checklist.

## Structure

```
skills/
  harness-foundation/          # Five-subsystem model, diagnostic loop, DoD (Lectures 01-04)
  state-and-scope/             # State persistence, WIP=1, feature lists, init phase (Lectures 05-08)
  verification-and-lifecycle/  # Three-layer termination, dual gate, clean-state protocol (Lectures 09-12)
  harness-projects/            # The six progressive reference projects from the curriculum
  harness-bootstrap/           # Composes the four skills above into a concrete "bootstrap a new project" procedure
    assets/
      hooks/                   # bd-wip-gate.sh, lint-on-save.sh, stop-gate.sh — copied verbatim into target projects
      scripts/mkid-helper.sh   # bash helper for seeding bd issues per the epic/dependency rubric
      settings.hooks.json      # hooks block merged into a target project's .claude/settings.json
      templates/               # *.template files with {{TOKEN}} placeholders, filled in per target project
docs/
  foundation-lectures-summary.md
  state-scope-lectures-summary.md
  verification-lifecycle-lectures-summary.md
```

`docs/*-lectures-summary.md` are the source lecture material; each `SKILL.md` is a condensed, actionable distillation of the corresponding lectures (foundation → Lectures 01-04, state-and-scope → 05-08, verification-and-lifecycle → 09-12) plus a `harness-projects` skill covering the six-project reference architecture and `harness-bootstrap`, which composes all four into a single executable procedure.

## Architecture: methodology skills vs. the bootstrap skill

The four methodology skills (`harness-foundation`, `state-and-scope`, `verification-and-lifecycle`, `harness-projects`) are the "why" — pure `SKILL.md` files with no bundled assets, meant to be read in that dependency order (later skills assume the concepts from earlier ones: five subsystems → state/WIP/feature-lists → verification gates/lifecycle → the projects that combine all of it).

`harness-bootstrap` is the "how": a single skill that turns a PRD into a complete working agent harness in one pass (tech-stack decision doc, `AGENTS.md`/`CLAUDE.md`, a `bd`-seeded issue tree, verification hooks, quality-standards/decisions docs). It references the four methodology skills for rationale but is self-contained via a condensed cheat-sheet, so it still works if the other skills aren't installed on a given machine.

Key mechanics specific to `harness-bootstrap` (see `skills/harness-bootstrap/SKILL.md` for the full step-by-step):
- It relies on `bd` (the beads issue tracker) as a hard dependency — `bd init` generates the base `AGENTS.md`/`CLAUDE.md`/`.claude/settings.json`, and the skill only *layers* project-specific content on top, never hand-writing those files from scratch.
- Epics are always top-level; cross-epic sequencing is `bd dep add`, never epic-as-parent-of-epic. Getting this backwards (core-differentiator logic depending on the API layer rather than the reverse) is the most likely subtle bug, which is why the skill has an explicit `bd dep list` check for it.
- Template files use `{{TOKEN}}` placeholders and `<!-- HTML comment -->` guidance blocks that must all be filled/deleted before the harness is considered done — the self-review checklist (step 9) greps for both.
- Bundled assets live under `skills/harness-bootstrap/assets/` in this repo; at runtime the skill is installed to `~/.claude/skills/harness-bootstrap/` and all asset paths in the skill are relative to whichever of those two locations it's invoked from. **This repo's copy under `skills/harness-bootstrap/assets/` is the authoritative source** — the installed copy is a runtime artifact.

## Conventions

- Every skill is exactly one `SKILL.md` file (filename is always `SKILL.md`, uppercase) with YAML frontmatter: `name`, `description`, `trigger`. `name` matches the containing directory.
- Only `harness-bootstrap` has a supplemental `assets/` subtree; the four methodology skills are pure documentation with no bundled files.
- When editing a methodology `SKILL.md`, keep it consistent with its source lecture summary in `docs/` — the skill is meant to be a condensed, actionable version of that document, not a divergent one.
- When editing `skills/harness-bootstrap/assets/hooks/*.sh` or `mkid-helper.sh`, remember they get copied verbatim into other projects' repos — keep them dependency-light (they assume only `bash`, `jq`, and `bd` on PATH) and re-check the "smoke test with synthetic stdin" examples in `harness-bootstrap/SKILL.md` step 4 still match if you change hook behavior.

## Note on the existing AGENTS.md

The root `AGENTS.md` in this repo describes an `evals/harness-bootstrap-skill/` directory and a `.omo/` directory — neither exists in the current tree. Treat those references as stale/aspirational, not as ground truth about repo layout.
