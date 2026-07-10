# PROJECT KNOWLEDGE BASE

**Generated:** 2026-07-07
**Git:** no repo (standalone project directory)

## OVERVIEW

Learn Harness Engineering curriculum — skill definitions, lecture summaries, and eval infrastructure for building production-grade agent harnesses. All markdown, shell scripts, and Python; no application code.

## STRUCTURE

```
harness-engineering/
├── docs/        # Lecture summaries (foundation, state-scope, verification-lifecycle)
├── skills/      # Skill definitions (4 SKILL.md files)
│   ├── harness-foundation/       # Five-subsystem model, diagnostic loop, DoD
│   ├── harness-projects/         # Six progressive projects
│   ├── state-and-scope/          # Session persistence, WIP, feature lists
│   └── verification-and-lifecycle/ # Verification gates, observability, lifecycle
├── evals/       # Eval infrastructure for harness-bootstrap skill
│   └── harness-bootstrap-skill/  # Scenarios, runner, graders, runs
└── .omo/        # OpenCode session state
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Understanding a skill's methodology | `skills/<name>/SKILL.md` | Each skill is a single file with frontmatter |
| Lecture summaries | `docs/<topic>-lectures-summary.md` | Foundation, state-scope, verification-lifecycle |
| Eval plan & design decisions | `evals/harness-bootstrap-skill/PLAN.md` | Detailed rationale for every design choice |
| Eval grader scripts | `evals/harness-bootstrap-skill/graders/` | Mechanical grader + LLM judge rubric |
| Eval runner prompts & setup | `evals/harness-bootstrap-skill/runner/` | Per-arm prompts, scenario setup |
| Eval scenarios (PRDs + answer keys) | `evals/harness-bootstrap-skill/scenarios/<NN-name>/` | 5 scenarios |
| Eval run results | `evals/harness-bootstrap-skill/runs/` | Organized by scenario and arm |

## CONVENTIONS

- Every skill is one `SKILL.md` file with YAML frontmatter (`name`, `description`, `trigger`).
- Eval runs use `bd` (beads tracker) for issue management, `jq` for JSON queries.
- Control-arm evals get methodology docs but no skill template artifacts — `[skill-only]` grader checks are skipped for control.
- Headless eval runs override `AskUserQuestion` steps with "default-and-log" to DECISIONS.md.
- Filename pattern: `SKILL.md` (singular, uppercase) for all skills.

## ANTI-PATTERNS

- **Eval artifacts in version control**: `.beads/` directories contain embedded dolt databases — eval-run output, not project source.
- **Scoring a control arm against skill-specific mechanics**: Grader uses `[skill-only]` tagging to avoid false failures.
- **Silent guessing on ambiguous PRD questions**: Must log default decisions to DECISIONS.md.

## COMMANDS

```bash
# No build/run commands — this is a documentation and eval project.
# Eval runner expects: bd, jq, git on PATH.
```

## NOTES

- The `harness-bootstrap` skill is version-controlled in `skills/harness-bootstrap/` and installable to `~/.claude/skills/harness-bootstrap/`. The user-level install is the runtime copy; the repo copy is the authoritative source. This repo's `evals/` tests that skill.
- `evals/harness-bootstrap-skill/runs/` is 99% of this repo's file count — all generated eval data, not manually maintained content.
