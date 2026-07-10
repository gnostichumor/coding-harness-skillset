<!-- Append everything below to CLAUDE.md, AFTER any existing bd-managed
     BEGIN BEADS INTEGRATION / END BEADS INTEGRATION marker blocks that
     `bd init`/`bd setup claude` generated. Never edit inside those
     markers -- bd owns and regenerates them. Fill every {{TOKEN}} below;
     leave no placeholder text OR guidance comments (including this one)
     in the committed file -- delete every HTML comment in this template
     once you've used its instructions. -->

## Project Status

**Pre-implementation.** As of this writing, only `docs/`, the bd issue
tracker, and this harness scaffolding exist — no application code, no
tests, no Dockerfile, no CI (unless the tech-stack-decision step chose to
scaffold a minimal tooling config alongside this). Run `bd ready` to see
what's next. Don't skip ahead of the ready issue — the verification
commands below don't exist until the scaffolding issue lands.

## Session Start Checklist

Initialization and implementation optimize for different things — explore
first, then execute (harness-engineering Lecture 06). Before writing any
code, confirm all four:

- [ ] **Can start?** `bd ready` shows an unblocked issue, and (once the
      scaffolding issue is closed) the project's declared dependency
      install command succeeds.
- [ ] **Can test?** The verification commands in "Build & Test" below
      actually run (even if they don't exist yet, confirm *that* — don't
      assume).
- [ ] **Can see progress?** `git status` is clean or its state is
      understood; `bd list --status=in_progress` matches what you're
      about to claim.
- [ ] **Can pick up next steps?** `bd show <id>` on the ready issue has a
      clear Definition of Done in `--acceptance` (Behavior/Verification/
      State). If it doesn't, fix the issue before claiming it — don't guess.

Only after this checklist passes: `bd update <id> --claim` (WIP=1 is
enforced by `.claude/hooks/bd-wip-gate.sh` — a second claim while one issue
is `in_progress` will be denied).

## Build & Test

{{VERIFICATION_COMMANDS_BLOCK}}
<!-- Fill with the actual lint/type-check/test commands chosen in the
     tech-stack-decision step, e.g.:
       ruff check .
       ruff format --check .
       mypy --strict src/
       pytest -q
     If verification is being deliberately deferred to a scaffolding
     issue (the default -- see SKILL.md step 2), say so explicitly here
     instead of listing commands that don't exist yet:
       "Not yet scaffolded -- see Project Status above. The commands
       this harness expects to exist once the scaffolding issue lands:
       <list them anyway, so a future session knows the target>." -->

`.claude/hooks/lint-on-save.sh` runs the matching formatter/linter after
every Edit/Write (dispatches by file extension; no-ops for stacks/tools
not present). `.claude/hooks/stop-gate.sh` blocks session Stop if
tests/lint fail on changed files for the detected stack (also a no-op
pre-scaffolding). Both degrade gracefully — see the scripts' comments.

## Architecture Overview

Full implementation decisions live in `docs/architecture.md`; product
requirements live in {{PRD_PATH}}. One-paragraph summary:

{{ONE_PARAGRAPH_ARCHITECTURE_SUMMARY}}

## Conventions & Patterns

{{CONVENTIONS_BULLETS}}
<!-- Always include, at minimum, these two (fill in specifics):
  - Config as source of truth: {{CONFIG_FILE}} = every static tunable;
    {{STATE_STORE}} = mutable runtime state. Never mix the two. Full
    rationale: docs/architecture.md §<N>.
  - This project's own dev work is tracked in `bd`, not markdown. No
    FEATURES.md/PROGRESS.md — `bd ready` / `bd list --status=in_progress`
    is the live task list. See DECISIONS.md for why, and
    .claude/hooks/bd-wip-gate.sh for the WIP=1 enforcement mechanism.
  Add a Frontend/API boundary rule bullet if this project has both a UI
  and an API surface (see docs/architecture.md's boundary-rule section
  in the architecture template). Add stack-specific conventions (secrets
  handling, pinned dependency policy, adapter patterns, etc.) as needed. -->

## Definition of Done

Every bd issue's `--acceptance` field should be a checklist of
**verifiable** conditions, not vibes. Full format and the three-layer
termination check (self-check / verification / validation) live in
`docs/quality-standards.md`. Minimal shape:

```
- [ ] <behavior implemented>
- [ ] {{TEST_COMMAND}} passes (new + existing tests)
- [ ] {{LINT_COMMAND}} / {{TYPECHECK_COMMAND}} clean
- [ ] <validation: hit a live endpoint, or manual check against the running dev environment>
```
