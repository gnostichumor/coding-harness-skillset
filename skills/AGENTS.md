# SKILL DIRECTORY

## OVERVIEW

Skill definitions for Learn Harness Engineering. Four methodology skills ("why") + one bootstrap skill ("how") that composes them into a concrete project-bootstrapping procedure with bundled assets (hooks, scripts, templates).

## STRUCTURE

| Directory | Skill | Covers |
|-----------|-------|--------|
| `harness-foundation/` | Foundation | Five-subsystem model, diagnostic loop, Definition of Done (Lectures 01-04) |
| `state-and-scope/` | State & Scope | Session persistence, WIP limits, feature lists, init phases (Lectures 05-08) |
| `verification-and-lifecycle/` | Verification & Lifecycle | Verification gates, observability, session lifecycle (Lectures 09-12) |
| `harness-projects/` | Projects | Six progressive projects from the curriculum |
| `harness-bootstrap/` | Bootstrap | One-shot harness creation from a PRD — composes all four methodology skills with bundled hooks, scripts, and templates |

## WHERE TO LOOK

- **To load a skill**: `skill(name="<skill-name>")` — frontmatter name matches the directory.
- **To understand the full methodology**: Read in dependency order: foundation → state-and-scope → verification-and-lifecycle → projects.
- **To bootstrap a project**: Load `harness-bootstrap` — it references all four methodology skills for the "why" and provides the concrete "how."
- **Four methodology skills are pure SKILL.md files** with no supplemental assets. `harness-bootstrap/` includes an `assets/` subtree with hooks, scripts, settings, and templates.

## CONVENTIONS

- All skills use the same YAML frontmatter schema: `name`, `description`, `trigger`.
- Methodology skills are independent but designed to be loaded in sequence. Later skills reference earlier ones.
- The `harness-bootstrap` skill composes all four methodology skills and ships with executable assets in `assets/`.
