# SKILL DIRECTORY

## OVERVIEW

Skill definitions for Learn Harness Engineering. Each subdirectory is one standalone `SKILL.md` — the methodology's executable knowledge, loadable by OpenCode agents.

## STRUCTURE

| Directory | Skill | Covers |
|-----------|-------|--------|
| `harness-foundation/` | Foundation | Five-subsystem model, diagnostic loop, Definition of Done (Lectures 01-04) |
| `state-and-scope/` | State & Scope | Session persistence, WIP limits, feature lists, init phases (Lectures 05-08) |
| `verification-and-lifecycle/` | Verification & Lifecycle | Verification gates, observability, session lifecycle (Lectures 09-12) |
| `harness-projects/` | Projects | Six progressive projects from the curriculum |

## WHERE TO LOOK

- **To load a skill**: `skill(name="<skill-name>")` — frontmatter name matches the directory.
- **To understand the full methodology**: Read in dependency order: foundation → state-and-scope → verification-and-lifecycle → projects.
- **Each SKILL.md is the single source of truth** for that topic. No supplemental files per skill.

## CONVENTIONS

- All skills use the same YAML frontmatter schema: `name`, `description`, `trigger`.
- Skills are independent but designed to be loaded in sequence. Later skills reference earlier ones.
- The `harness-bootstrap` skill (user-level, not in this repo) composes all four.
