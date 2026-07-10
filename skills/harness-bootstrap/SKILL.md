---
name: harness-bootstrap
description: One-shot creation of a full agent harness (tech-stack decision, AGENTS.md/CLAUDE.md, bd issue tracker seeded from the PRD, verification hooks, quality-standards/decision-log docs) for a brand-new project, given only a PRD as input. Applies the harness-engineering methodology (five-subsystem model, feature-list triple structure, WIP=1, three-layer termination) via the harness-foundation/state-and-scope/verification-and-lifecycle skills, plus concrete bd/hook/template mechanics those skills don't cover.
trigger: "When the user asks to bootstrap/scaffold/spin up a project harness for a new repo that has a PRD but no code yet, or says 'set up the harness' / 'do the harness-engineering setup' for a project."
---

# Harness Bootstrap

Turns a PRD into a working agent harness in one pass: a decided tech stack
(`docs/architecture.md`), layered agent instructions (`AGENTS.md`/
`CLAUDE.md`), a `bd`-tracked issue tree covering every requirement, and
verification hooks — so the *next* session can run `bd ready` and start
building real features immediately, with guardrails already live.

**Prerequisite skills** — invoke these via the Skill tool for the
underlying methodology; this skill is the concrete "how," those are the
"why." Read them (or at least `harness-foundation`) before step 1 if
you're not already familiar with the five-subsystem model:
- `harness-foundation` — five-subsystem model, diagnostic loop, Definition of Done
- `state-and-scope` — state persistence, WIP=1, initialization phase, feature-list triple structure
- `verification-and-lifecycle` — three-layer termination, verification-validation dual gate, clean-state protocol
- `harness-projects` — the six-project reference architecture this whole pattern is drawn from

**Condensed cheat-sheet** (so this skill works even if the above aren't
available on this machine):

| Concept | Rule |
|---|---|
| Five subsystems | Instructions, Tools, Environment, State, Feedback — every harness gap maps to exactly one |
| Definition of Done | Verifiable by command, not by feeling. One DoD per task. |
| WIP=1 | Only one unit of work `in_progress` at a time; the harness enforces this, not the agent's discipline |
| Feature list triple | Every unit of work has Behavior / Verification / State |
| Three-layer termination | Self-check (agent) → Verification (executable command) → Validation (external/live confirmation) — all three required |
| Clean state | End of session: committed, state files/issue tracker accurate, no broken tests |

**Bundled assets** (all paths relative to this skill's directory,
`~/.claude/skills/harness-bootstrap/`):
```
assets/hooks/bd-wip-gate.sh       # PreToolUse Bash hook, WIP=1 gate (language-agnostic, copy verbatim)
assets/hooks/lint-on-save.sh      # PostToolUse Edit|Write hook, dispatches by extension
assets/hooks/stop-gate.sh         # Stop hook, dispatches by manifest file (pyproject.toml/package.json/go.mod/Cargo.toml)
assets/settings.hooks.json        # hooks block to MERGE into .claude/settings.json
assets/templates/claude-md-addendum.md
assets/templates/agents-md-addendum.md
assets/templates/architecture.md.template
assets/templates/quality-standards.md.template
assets/templates/decisions.md.template
assets/templates/readme.md.template
assets/scripts/mkid-helper.sh     # bash helper for seeding bd issues + the epic/dependency rubric
```

---

## Step 0 — Locate the PRD and confirm prerequisites

- Find the PRD (ask the user for the path if not obvious; check `docs/*prd*.md`, `PRD.md`, `docs/requirements.md`). **A PRD is a hard prerequisite** — if none exists, stop and say so rather than inventing requirements.
- Confirm `bd` is installed (`bd --version`); if missing, stop and tell the user — this whole harness is built on it. `br` is optional and only relevant if the project itself uses Beads Rust as a tracked dependency (not the same thing as this project's own dev tracking).
- Confirm `git`, `jq` are available (both hook scripts and the seeding script depend on `jq`).
- Determine the project root (existing empty-ish directory, or one to create). `cd` there for everything below.

## Step 1 — Tech-stack decision (skip if `docs/architecture.md` already exists)

If `docs/architecture.md` already exists, read it and treat it as ground truth — do not re-derive the stack. Otherwise:

1. Read the full PRD.
2. Gather hard constraints. Check this conversation for anything the user already stated (language, hosting target, must-use libraries, TDD requirement, config-as-source-of-truth requirement — the last two are common defaults worth asking about explicitly if unstated). If material constraints are genuinely unclear, ask via **AskUserQuestion** with a sensible "Recommended" default rather than blocking — e.g. language/runtime, deployment target (containerized self-host / cloud PaaS / serverless / library-only), TDD framework preference. Don't ask about things you can reasonably default (e.g. "should tests exist" — yes, always).
3. Propose the stack and write `docs/architecture.md` from `assets/templates/architecture.md.template`. Fill every `{{TOKEN}}`; delete template sections that don't apply (no Frontend/API boundary section for a CLI-only project, etc.) and delete every `<!-- HTML comment -->` guidance block once used. Every row in the stack table needs a real "Why," not a restated choice.
4. **Always** fill in §3 (Config as source of truth) — one file for static tunables, one store for mutable/user-generated state. This is a fixed methodology preference, not optional, even for small projects: pick real names for `{{CONFIG_FILE}}` / `{{STATE_STORE}}` and real example tunables/state.
5. §5, the core-differentiator section: identify the ONE piece of business logic that is the actual reason this project exists (not boilerplate CRUD) and spell out its exact rule unambiguously. **If any part of that rule is ambiguous or you're inferring it rather than reading it directly from the PRD, ask the user via AskUserQuestion before writing it down** — a wrong core-rule committed to a document a future agent will treat as ground truth is the most expensive mistake this skill can make. Record the confirmation in `DECISIONS.md` (step 5c) so it's traceable.
6. If the PRD has open questions / unresolved decisions beyond the stack itself, don't resolve them by fiat — they get tracked in step 6 as `human`-labeled bd chores, **except** (a) any that a stack/architecture decision genuinely already settles (note that resolution explicitly in the PRD's open-questions section, pointing at `docs/architecture.md`, rather than leaving a stale contradiction), or (b) any the PRD itself signals is trivial (see step 6 rule 5's triviality test) — those get resolved directly, not tracked as a chore at all.

## Step 2 — Initialize git + bd

```bash
git init                                          # if not already a repo
bd init --agents-profile full --non-interactive
```
This single command creates `AGENTS.md`, `CLAUDE.md`, `.claude/settings.json` (with a `SessionStart` hook running `bd prime`), `.agents/skills/beads/`, `.codex/` files, and commits them. **Do not hand-write these from scratch** — `bd init` already does it correctly; your job is to layer project-specific content on top (step 3) without touching anything between `<!-- BEGIN BEADS ... -->` / `<!-- END BEADS ... -->` markers (bd owns and regenerates those).

## Step 3 — Layer project-specific content into AGENTS.md / CLAUDE.md

Append (never insert inside bd's managed blocks) the filled-in content from:
- `assets/templates/claude-md-addendum.md` → `CLAUDE.md`
- `assets/templates/agents-md-addendum.md` → `AGENTS.md`

Fill every `{{TOKEN}}` using the stack decided in step 1. The Session Start Checklist section is stack-agnostic — copy it verbatim. **Every template is full of `<!-- HTML comment -->` guidance blocks explaining what to put in each section — delete all of them once used.** Left in place, they're at best clutter and at worst read as literal instructions to a future session.

## Step 4 — Install verification hooks

```bash
mkdir -p .claude/hooks
cp ~/.claude/skills/harness-bootstrap/assets/hooks/*.sh .claude/hooks/
chmod +x .claude/hooks/*.sh
```

Merge (don't overwrite) the hooks block into `.claude/settings.json` — it already has a `SessionStart` entry from `bd init`, and jq's `*` operator deep-merges objects so this combines cleanly:

```bash
jq -s '.[0] * .[1]' .claude/settings.json ~/.claude/skills/harness-bootstrap/assets/settings.hooks.json > /tmp/settings.merged.json \
  && mv /tmp/settings.merged.json .claude/settings.json
jq . .claude/settings.json >/dev/null && echo "valid JSON"
```

**Smoke-test every hook with synthetic stdin before trusting it** — this is the step most likely to hide a bug (JSON escaping, an unbound-variable error under `set -u`, a typo in a jq filter). Don't skip this because the scripts are copied verbatim; verify they still no-op cleanly in *this* project:

```bash
echo '{"tool_input":{"file_path":"/tmp/nope.md"}}' | .claude/hooks/lint-on-save.sh; echo "exit=$?"
echo '{"stop_hook_active":false}' | .claude/hooks/stop-gate.sh; echo "exit=$?"
echo '{"tool_input":{"command":"ls"}}' | .claude/hooks/bd-wip-gate.sh; echo "exit=$?"
```
All three should print nothing and `exit=0` on a fresh, pre-scaffolding repo. If you want to verify the WIP gate actually *blocks*, create a throwaway bd issue, claim it, pipe a second `bd update ... --claim` command through the hook, confirm it denies, then delete the throwaway issue (`bd delete <id> --force`) — don't leave test cruft in the tracker.

**Hooks require a Claude Code restart to take effect in the current session** — don't claim they're "live" without one; report them as installed-and-smoke-tested, not as verified-in-this-running-session, unless you actually restarted.

## Step 5 — Write the remaining docs

From `assets/templates/`, filling every `{{TOKEN}}` and deleting every `<!-- HTML comment -->` guidance block once used (same rule as step 3):
- `quality-standards.md.template` → `docs/quality-standards.md`
- `decisions.md.template` → `DECISIONS.md` (seed with one entry per architecture decision from step 1, plus the boilerplate "tracked in bd, not markdown" entry — always include that one verbatim, it's a fixed methodology choice)
- `readme.md.template` → `README.md`
- `architecture.md.template` (already written in step 1) — double-check its guidance comments were deleted too if you filled it out earlier without following this rule

## Step 6 — Decompose the PRD into bd epics/issues

This is the step requiring the most judgment — there's no fixed script, only a rubric. `source ~/.claude/skills/harness-bootstrap/assets/scripts/mkid-helper.sh` for the `mkid()` helper (has the `set -u` empty-array bug already fixed — don't reinvent it) and follow its rubric comments. Key rules, stated again because they're easy to get wrong under time pressure:

1. **Every epic is top-level.** Never pass one epic's ID as another epic's `--parent` — that's a hierarchy bug (nests an epic inside an epic), not a build-order dependency. Cross-epic build order is expressed *only* via `bd dep add <later-epic> <earlier-epic>`.
2. **Every requirement/feature issue's `--parent` is its owning epic** (flat, one level below the epic). Sequencing between sibling features in the same epic is `bd dep add`, never parent-chaining one sibling onto the previous one.
3. Identify epics by data/control flow, not PRD section order: foundations first (env/code scaffolding, config+state), then ingestion/adapters (if any external data sources), then the core-differentiator logic (docs/architecture.md §5), then the API layer (if externally-facing — per the boundary rule, this comes *before* any UI epic), then the UI (a pure API consumer, if any), then packaging/deployment last. **This order is a dependency direction, not just a list** — the core-differentiator epic must be buildable and blocking-ready *before* the API epic (API depends on core logic being ready, never the reverse), because the API is just a thin layer that exposes the core logic, not something the core logic needs. After wiring the cross-epic `bd dep add` edges, run `bd dep list <core-differentiator-epic-id>` and confirm it does **not** list the API (or UI) epic as a dependency — if it does, the edge was wired backwards (an easy mistake: `bd dep add <blocked> <blocker>` takes the blocked issue first, and it's easy to swap them when the two epics feel like they "obviously" relate). A backwards edge still makes `bd ready` look correct (rule 6's aggregate check can't tell direction, only that something blocks the issue), so this specific per-epic direction check is the only thing that catches it.
4. Every issue's `--description`/`--acceptance` uses the **Behavior / Verification / State** triple — write real, specific content, not restated titles. Verification must name an actual command or test approach.
5. PRD open questions / unresolved decisions → `chore` issues, `--labels human`, parented to the epic they most affect — **but first apply a triviality test**: if the PRD itself signals the question is low-stakes (says things like "trivial," "pick a sensible default," "not a project-shaping decision," or just asks for a single config value with no real downstream branching), **resolve it directly instead** — pick the sensible default, record the choice and one-line rationale in `DECISIONS.md`, and do not create a chore for it at all. Only create a chore for questions where a wrong guess would cause real rework (schema choice, a feature that can't be correctly built without the answer, a decision with actual downstream branching). This mirrors the headless-default pattern already used for stack decisions in step 1 — a trivial default doesn't need to become tracked work any more than "should tests exist" needs an AskUserQuestion. For genuine chores: add `bd dep add <blocked-feature> <open-question>` only when it's a genuine hard blocker (e.g. the feature can't be correctly specified without the answer), not for merely-related context. **Immediately after that `bd dep add` call, run `bd dep list <blocked-feature>` and confirm the open-question issue's ID actually appears in the output.** Do not treat "I called `bd dep add`" or "I described the block in prose/acceptance-criteria" as sufficient — verify the edge landed before writing about it anywhere (FINAL REPORT, docs, commit message). A blocking claim that isn't backed by a verified `bd dep list` check is not true yet.
6. After seeding: `bd stats` and `bd ready`. Sanity-check that `bd ready` shows only the true entry point(s) (typically just the scaffolding epic) and everything else is blocked — if more than that is ready, you likely missed a dependency edge. **Note this aggregate check can miss a single missing edge**: if the blocked issue already has *other* incoming dependencies (e.g. from an earlier epic), it will still show as correctly blocked in `bd ready` even if the specific open-question edge from rule 5 was never added. `bd ready` passing is not proof any one specific edge exists — only the per-edge `bd dep list` check in rule 5 proves that.

## Step 7 — Ask about the Feedback subsystem's scope

Before committing, ask the user explicitly (**AskUserQuestion**, don't decide silently): leave verification fully stubbed until the scaffolding issue is worked (recommended default — matches "harness infra before code infra"), or add a minimal, app-code-free tooling config now (lint/type-check/test config + one trivial passing test, no application code) so the hooks are live immediately. Either is legitimate; the point is this is a real scope fork the user should make, not you.

## Step 8 — Commit

```bash
git add -A
git status   # review before committing -- confirm nothing unexpected is staged
git commit -m "..."
```
One commit is fine (bd's own init commit already happened separately in step 2). Verify `git status` is clean afterward.

## Step 9 — Self-review checklist (do this before declaring done)

- [ ] No epic has another epic as `--parent` (check: `bd list --json | jq '[.[] | select(.issue_type=="epic")]'` and inspect each one's parent field)
- [ ] Every requirement/feature issue has a real Behavior/Verification/State triple in its acceptance criteria, not a placeholder
- [ ] `AGENTS.md`/`CLAUDE.md`/`docs/*.md`/`README.md`/`DECISIONS.md` contain **zero** unfilled `{{TOKEN}}` placeholders: run `grep -rn '{{' . --include='*.md'` from the project root — it should return nothing
- [ ] Same files contain **zero** leftover `<!-- guidance comments -->` from the templates: run `grep -rn '<!--' . --include='*.md' | grep -v BEADS` from the project root — it should return nothing. (Don't touch the `<!-- BEGIN/END BEADS ... -->` markers `bd init` writes into `AGENTS.md`/`CLAUDE.md` — those are legitimate, bd-managed, and excluded by this filter on purpose.)
- [ ] All three hooks are executable and were smoke-tested (step 4), not just copied
- [ ] `bd ready` shows exactly the expected entry-point issue(s)
- [ ] For every open-question chore claimed as a hard blocker, `bd dep list <blocked-issue-id>` was actually run and shows that chore's ID — not just described in prose or assumed from `bd ready` looking correct
- [ ] No open-question chore exists for a question the PRD itself signals as trivial (step 6 rule 5's triviality test) — trivial defaults should be resolved directly in `DECISIONS.md`, not tracked as chores
- [ ] `bd dep list <core-differentiator-epic-id>` was run and does not list the API or UI epic as a dependency (core-differentiator must block the API, never depend on it — see step 6 rule 3)
- [ ] `docs/architecture.md` §5's core-differentiator rule was either read directly from the PRD or explicitly confirmed with the user (step 1.5) — not silently inferred
- [ ] Working tree is clean (`git status`)
- [ ] If a stronger model/reviewer is available (e.g. an `advisor`-style tool), use it before declaring done — this skill was itself built after such a review caught real gaps (missing session-start checklist, a dangling doc reference, an inconsistently-resolved open question). Don't skip that check just because a checklist exists; the checklist won't catch what it wasn't written to catch.
