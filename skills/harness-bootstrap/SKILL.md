---
name: harness-bootstrap
description: One-shot creation of a full agent harness (tech-stack decision, AGENTS.md/CLAUDE.md, a br/beads_rust issue tracker seeded from the PRD or from an existing codebase, verification hooks, quality-standards/decision-log docs) for a project — whether it's a brand-new repo with only a PRD, or an existing repo that already has code, tooling, and conventions in place. Applies the harness-engineering methodology (five-subsystem model, feature-list triple structure, WIP=1, three-layer termination) via the harness-foundation/state-and-scope/verification-and-lifecycle skills, plus concrete br/hook/template mechanics those skills don't cover.
when_to_use: "When the user asks to bootstrap/scaffold/spin up a project harness — for a new repo that has a PRD but no code yet, OR for an existing repo/codebase that needs harness infrastructure retrofitted onto it — or says 'set up the harness' / 'do the harness-engineering setup' for a project."
---

# Harness Bootstrap

Turns a PRD (or an existing codebase's current state) into a working agent
harness in one pass: a decided tech stack (`docs/architecture.md`), layered
agent instructions (`AGENTS.md`/`CLAUDE.md`), a `br` (beads_rust)-tracked
issue tree covering every requirement, and verification hooks — so the
*next* session can run `br ready` and start building real features
immediately, with guardrails already live.

This works in two modes:
- **Greenfield** — an empty-ish project directory with only a PRD. The
  stack is *decided* and the issue tree is seeded from scratch.
- **Brownfield** — an existing repo with real code, tooling, and
  conventions already in place. The stack is *detected*, not decided;
  existing docs/config/CI are extended, never overwritten; and the issue
  tree is seeded only for the gap between what the PRD asks for and what
  the code already does. See Step 0 for how to tell which mode you're in
  and Steps 1/3/5/6 for the brownfield branch of each step.

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

**Bundled assets** — the authoritative source is version-controlled at
`skills/harness-bootstrap/assets/` in the harness-engineering repo; at
runtime this skill is installed to `~/.claude/skills/harness-bootstrap/`
(all paths below are relative to whichever of those two locations the
skill is being invoked from):
```
assets/hooks/lint-on-save.sh      # PostToolUse Edit|Write hook, dispatches by extension
assets/hooks/stop-gate.sh         # Stop hook, dispatches by manifest file (pyproject.toml/package.json/go.mod/Cargo.toml)
assets/settings.hooks.json        # hooks block to MERGE into .claude/settings.json
assets/templates/claude-md-addendum.md
assets/templates/agents-md-addendum.md
assets/templates/architecture.md.template
assets/templates/quality-standards.md.template
assets/templates/decisions.md.template
assets/templates/readme.md.template
assets/scripts/mkid-helper.sh     # bash helper for seeding br issues + the epic/dependency rubric
```

Note there is no WIP-gate hook script anymore — `br` enforces WIP=1
natively via a workspace capacity policy (Step 2b), which is stronger than
a `PreToolUse` hook that pattern-matches bash commands (it can't be
bypassed by invoking `br` a different way).

---

## Step 0 — Locate the PRD, confirm prerequisites, and classify the repo

- Find the PRD (ask the user for the path if not obvious; check `docs/*prd*.md`, `PRD.md`, `docs/requirements.md`). **A PRD or equivalent product-requirements source is a hard prerequisite** — if none exists, stop and say so rather than inventing requirements. (For a brownfield repo, the "PRD" may be thinner — a README, a design doc, or the user's description of what the project already does and what's next; that's fine, but confirm with the user what the source of truth for requirements is before proceeding.)
- Confirm `br` is installed (`br --version`); if missing, stop and tell the user — this whole harness is built on it (install via the instructions at https://github.com/Dicklesworthstone/beads_rust if needed).
- Confirm `git`, `jq` are available (the hook scripts and the seeding script depend on `jq`).
- Determine the project root (existing empty-ish directory, one to create, or an existing repo). `cd` there for everything below.
- **Classify the repo** — this determines which branch of Steps 1/3/5/6 to follow:
  - **Greenfield**: no source code, or only scaffolding placeholders; no `.beads/` directory yet.
  - **Brownfield**: real application code exists (check for more than a handful of source files, an existing test suite, existing CI config, existing `README.md`/`AGENTS.md`/`CLAUDE.md` with real project-specific content), and/or `.beads/` already exists (br was already initialized, possibly by a previous partial bootstrap or by the team directly).
  - Say out loud which mode you're operating in before continuing — don't silently guess; if it's ambiguous (e.g. a repo with only CI config and no app code yet), ask the user via **AskUserQuestion**.

## Step 1 — Tech-stack decision (skip if `docs/architecture.md` already exists)

If `docs/architecture.md` already exists, read it and treat it as ground truth — do not re-derive the stack. Otherwise, branch on Step 0's classification:

**Brownfield — detect, don't decide:**
1. Inventory the existing stack directly from what's on disk: manifest files (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, etc.), lockfiles, lint/type-check/test config (`.eslintrc*`, `ruff.toml`/`pyproject.toml [tool.ruff]`, `tsconfig.json`, etc.), CI config (`.github/workflows/*`), and any existing `Dockerfile`/deployment config.
2. Write `docs/architecture.md` from `assets/templates/architecture.md.template` documenting the stack **as it already exists**, not as a fresh proposal. Every "Why" column entry should read as "already the established convention in this repo" (with the concrete evidence — the manifest/config file — named), not a hypothetical rationale. Do not propose alternatives to an already-working, already-adopted stack; that's scope creep for a bootstrap pass.
3. Only ask the user (via **AskUserQuestion**) about things genuinely *not* answered by the existing setup — e.g. the PRD asks for a new capability that needs a new dependency/service the current stack doesn't have, or there's a real ambiguity (two competing conventions found in the repo, or CI configured for a stack the code doesn't actually use).
4. Still fill in §3 (Config as source of truth) and §5 (core-differentiator) fully per the greenfield rules below — these are about *this PRD's* requirements, not about the stack, so brownfield doesn't skip them just because the stack itself is pre-decided.

**Greenfield — decide it:**
1. Read the full PRD.
2. Gather hard constraints. Check this conversation for anything the user already stated (language, hosting target, must-use libraries, TDD requirement, config-as-source-of-truth requirement — the last two are common defaults worth asking about explicitly if unstated). If material constraints are genuinely unclear, ask via **AskUserQuestion** with a sensible "Recommended" default rather than blocking — e.g. language/runtime, deployment target (containerized self-host / cloud PaaS / serverless / library-only), TDD framework preference. Don't ask about things you can reasonably default (e.g. "should tests exist" — yes, always).
3. Propose the stack and write `docs/architecture.md` from `assets/templates/architecture.md.template`. Fill every `{{TOKEN}}`; delete template sections that don't apply (no Frontend/API boundary section for a CLI-only project, etc.) and delete every `<!-- HTML comment -->` guidance block once used. Every row in the stack table needs a real "Why," not a restated choice.
4. **Always** fill in §3 (Config as source of truth) — one file for static tunables, one store for mutable/user-generated state. This is a fixed methodology preference, not optional, even for small projects: pick real names for `{{CONFIG_FILE}}` / `{{STATE_STORE}}` and real example tunables/state.
5. §5, the core-differentiator section: identify the ONE piece of business logic that is the actual reason this project exists (not boilerplate CRUD) and spell out its exact rule unambiguously. **If any part of that rule is ambiguous or you're inferring it rather than reading it directly from the PRD, ask the user via AskUserQuestion before writing it down** — a wrong core-rule committed to a document a future agent will treat as ground truth is the most expensive mistake this skill can make. Record the confirmation in `DECISIONS.md` (step 5c) so it's traceable.
6. If the PRD has open questions / unresolved decisions beyond the stack itself, don't resolve them by fiat — they get tracked in step 6 as `human`-labeled br chores, **except** (a) any that a stack/architecture decision genuinely already settles (note that resolution explicitly in the PRD's open-questions section, pointing at `docs/architecture.md`, rather than leaving a stale contradiction), or (b) any the PRD itself signals is trivial (see step 6 rule 5's triviality test) — those get resolved directly, not tracked as a chore at all.

## Step 2 — Initialize git + br

```bash
git init                # if not already a repo
br init                 # skip entirely if .beads/ already exists (brownfield, already tracked)
```

**`br init` is much thinner than `bd init` used to be**: it only creates
`.beads/` (`beads.db`, `issues.jsonl`, `config.yaml`, `policy.yaml`). It
does **not** scaffold `AGENTS.md`, `CLAUDE.md`, or `.claude/settings.json`,
and it does **not** commit anything automatically. This skill is fully
responsible for all three of those (Steps 2c, 3, 4) — hand-writing them
when absent, layering onto them additively when they already exist
(brownfield). Don't expect `br init` to do any of that for you.

Commit the tracker init on its own:
```bash
git add .beads && git commit -m "Initialize br (beads_rust) issue tracker"
```

### Step 2b — Configure native WIP=1 enforcement

Open `.beads/policy.yaml` (created by `br init`) and ensure it has a
capacity cap of 1 on `in_progress`:
```yaml
workflow:
  capacity:
    statuses:
      in_progress:
        hard: 1
```
If `policy.yaml` already has a `workflow.capacity.statuses` section
(brownfield — a team may have already tuned this), add just the
`in_progress.hard: 1` key rather than clobbering existing capacity config
for other statuses; if the repo has deliberately set a different
`in_progress` hard cap already, don't silently override it — ask the user,
since that's an existing team decision about their own workflow.

This is the actual WIP=1 enforcement mechanism, replacing what used to be
a bespoke `PreToolUse` hook: `br` rejects (with a full rollback of the
attempted transition) any `br update --claim` or `br update --status
in_progress` once the cap is already at 1, for *any* invocation path, not
just ones a hook's regex happens to match.

**Smoke-test it before trusting it:**
```bash
T1=$(br create "smoke-test-1" -t task --silent)
T2=$(br create "smoke-test-2" -t task --silent)
br update "$T1" --claim; echo "first claim exit=$?"
br update "$T2" --claim; echo "second claim exit=$? (expect nonzero / rejection)"
br close "$T1" -r "smoke test cleanup"
br update "$T2" --status open  # or br close, then delete both if br supports issue deletion
```
Confirm the second claim is actually refused with an error naming the
`in_progress` capacity limit, then clean up both throwaway issues — don't
leave test cruft in the tracker.

### Step 2c — Seed the beads workflow section in AGENTS.md

```bash
br agents --add --force
```
This writes (or refreshes) a beads-workflow section in `AGENTS.md` only —
unlike `bd init --agents-profile full`, it does **not** touch `CLAUDE.md`
or `.claude/settings.json`, and it doesn't manage a `.codex/` directory
either. Everything else in Steps 3-4 is this skill's own responsibility.

## Step 3 — Write/layer project-specific content into AGENTS.md / CLAUDE.md

**Greenfield** (files don't exist yet, or only contain what `br agents
--add` just wrote): write the full content from the templates below —
these are the whole file, not an "addendum" appended after some
tool-managed block, since `br` never touches `CLAUDE.md` and only manages
its own section of `AGENTS.md`.

**Brownfield** (files already have real project-specific content): don't
overwrite existing sections. Append the template content as new,
clearly-headed sections (or merge individual bullets into existing
equivalent sections if that's a cleaner fit) — the goal is additive,
reviewable diffs, never wholesale replacement of content a human already
wrote.

Either way, use:
- `assets/templates/claude-md-addendum.md` → `CLAUDE.md`
- `assets/templates/agents-md-addendum.md` → `AGENTS.md` (append below whatever `br agents --add --force` wrote in Step 2c — inspect the file first and don't edit inside anything that looks like a tool-managed section)

Fill every `{{TOKEN}}` using the stack decided/detected in step 1. The
Session Start Checklist section is stack-agnostic — copy it verbatim.
**Every template is full of `<!-- HTML comment -->` guidance blocks
explaining what to put in each section — delete all of them once used.**
Left in place, they're at best clutter and at worst read as literal
instructions to a future session.

## Step 4 — Install verification hooks

Determine the skill's asset directory (resolve relative to this SKILL.md's
location — at runtime that's `~/.claude/skills/harness-bootstrap/assets/`;
if invoked from the repo it's `skills/harness-bootstrap/assets/`):

```bash
mkdir -p .claude/hooks
cp ~/.claude/skills/harness-bootstrap/assets/hooks/*.sh .claude/hooks/
chmod +x .claude/hooks/*.sh
```

There are only two hook scripts now (`lint-on-save.sh`, `stop-gate.sh`) —
WIP=1 is enforced natively by `br` itself (Step 2b), not by a hook.

Merge (don't overwrite) the hooks block into `.claude/settings.json`. If
the file doesn't exist yet (typical for greenfield, since nothing
scaffolds it automatically anymore), create it as `{}` first; if it
already exists (brownfield — it may already have unrelated hooks or an
MCP config), merge additively:

```bash
[ -f .claude/settings.json ] || echo '{}' > .claude/settings.json
jq -s '.[0] * .[1]' .claude/settings.json ~/.claude/skills/harness-bootstrap/assets/settings.hooks.json > /tmp/settings.merged.json \
  && mv /tmp/settings.merged.json .claude/settings.json
jq . .claude/settings.json >/dev/null && echo "valid JSON"
```

**Smoke-test every hook with synthetic stdin before trusting it** — this is the step most likely to hide a bug (JSON escaping, an unbound-variable error under `set -u`, a typo in a jq filter). Don't skip this because the scripts are copied verbatim; verify they still no-op cleanly in *this* project:

```bash
echo '{"tool_input":{"file_path":"/tmp/nope.md"}}' | .claude/hooks/lint-on-save.sh; echo "exit=$?"
echo '{"stop_hook_active":false}' | .claude/hooks/stop-gate.sh; echo "exit=$?"
```
Both should print nothing and `exit=0` on a fresh, pre-scaffolding repo
(brownfield repos with real source files may legitimately have the
stop-gate actually run lint/test — that's expected, not a bug).

**Hooks require a Claude Code restart to take effect in the current session** — don't claim they're "live" without one; report them as installed-and-smoke-tested, not as verified-in-this-running-session, unless you actually restarted.

## Step 5 — Write the remaining docs

From `assets/templates/`, filling every `{{TOKEN}}` and deleting every `<!-- HTML comment -->` guidance block once used (same rule as step 3):
- `quality-standards.md.template` → `docs/quality-standards.md`
- `decisions.md.template` → `DECISIONS.md` (seed with one entry per architecture decision from step 1, plus the boilerplate "tracked in br, not markdown" entry — always include that one verbatim, it's a fixed methodology choice)
- `readme.md.template` → `README.md`
- `architecture.md.template` (already written in step 1) — double-check its guidance comments were deleted too if you filled it out earlier without following this rule

**Brownfield:** if any of these files already exist with real content
(most commonly `README.md`), do not overwrite them. Insert the missing
pieces (e.g. a "Task tracking" section pointing at `br ready`/`br list`,
a pointer to `DECISIONS.md`/`docs/quality-standards.md` if those are new)
as additive sections, preserving everything already there. If the repo
already has its own quality-bar doc or decision log under a different
name, don't create a duplicate — point `AGENTS.md`/`CLAUDE.md` at the
existing doc instead and skip writing the template for that file.

## Step 6 — Decompose the requirements into br epics/issues

This is the step requiring the most judgment — there's no fixed script, only a rubric. `source` the `mkid-helper.sh` from this skill's `assets/scripts/` directory (at runtime: `~/.claude/skills/harness-bootstrap/assets/scripts/mkid-helper.sh`; if invoked from the repo: `skills/harness-bootstrap/assets/scripts/mkid-helper.sh`) — it has the `set -u` empty-array bug already fixed, don't reinvent it — and follow its rubric comments. Key rules, stated again because they're easy to get wrong under time pressure:

**Brownfield addition — audit before seeding:** before creating any issue, check whether the requirement it would cover is already implemented. Read the relevant source/tests for each PRD requirement:
- **Fully implemented and verified** (a passing test or clear working code demonstrates it): still create the br issue for traceability, but create it pre-closed — `br create ... --status closed` (or create then `br close <id> -r "already implemented — see <file/test>"`) — so `br list`/`br stats` accurately reflect completed scope instead of making it look like open work. Don't skip creating it entirely; the issue tree should be a complete map of the PRD, not just the remaining gap.
- **Partially implemented**: create the issue `open`, but scope its Behavior/Verification/State triple to *only the remaining gap*, not the whole feature — cite what already exists and what's missing.
- **Not implemented**: create normally, per the rules below.
- If `.beads/` already has issues seeded (a previous partial bootstrap ran, or the team already tracks work in `br`): don't re-seed requirements that already have a matching open or closed issue — `br list --json` first and diff against the PRD's requirement list, only creating what's actually missing.

1. **Every epic is top-level.** Never pass one epic's ID as another epic's `--parent` — that's a hierarchy bug (nests an epic inside an epic), not a build-order dependency. Cross-epic build order is expressed *only* via `br dep add <later-epic> <earlier-epic>`.
2. **Every requirement/feature issue's `--parent` is its owning epic** (flat, one level below the epic). Sequencing between sibling features in the same epic is `br dep add`, never parent-chaining one sibling onto the previous one.
3. Identify epics by data/control flow, not PRD section order: foundations first (env/code scaffolding, config+state), then ingestion/adapters (if any external data sources), then the core-differentiator logic (docs/architecture.md §5), then the API layer (if externally-facing — per the boundary rule, this comes *before* any UI epic), then the UI (a pure API consumer, if any), then packaging/deployment last. **This order is a dependency direction, not just a list** — the core-differentiator epic must be buildable and blocking-ready *before* the API epic (API depends on core logic being ready, never the reverse), because the API is just a thin layer that exposes the core logic, not something the core logic needs. After wiring the cross-epic `br dep add` edges, run `br dep list <core-differentiator-epic-id>` and confirm it does **not** list the API (or UI) epic as a dependency — if it does, the edge was wired backwards (an easy mistake: `br dep add <blocked> <blocker>` takes the blocked issue first, and it's easy to swap them when the two epics feel like they "obviously" relate). A backwards edge still makes `br ready` look correct (rule 6's aggregate check can't tell direction, only that something blocks the issue), so this specific per-epic direction check is the only thing that catches it.
4. Every issue's `--description`/`--acceptance-criteria` uses the **Behavior / Verification / State** triple — write real, specific content, not restated titles. Verification must name an actual command or test approach.
5. PRD open questions / unresolved decisions → `chore` issues, `--labels human`, parented to the epic they most affect — **but first apply a triviality test**: if the PRD itself signals the question is low-stakes (says things like "trivial," "pick a sensible default," "not a project-shaping decision," or just asks for a single config value with no real downstream branching), **resolve it directly instead** — pick the sensible default, record the choice and one-line rationale in `DECISIONS.md`, and do not create a chore for it at all. Only create a chore for questions where a wrong guess would cause real rework (schema choice, a feature that can't be correctly built without the answer, a decision with actual downstream branching). This mirrors the headless-default pattern already used for stack decisions in step 1 — a trivial default doesn't need to become tracked work any more than "should tests exist" needs an AskUserQuestion. For genuine chores: add `br dep add <blocked-feature> <open-question>` only when it's a genuine hard blocker (e.g. the feature can't be correctly specified without the answer), not for merely-related context. **Immediately after that `br dep add` call, run `br dep list <blocked-feature>` and confirm the open-question issue's ID actually appears in the output.** Do not treat "I called `br dep add`" or "I described the block in prose/acceptance-criteria" as sufficient — verify the edge landed before writing about it anywhere (FINAL REPORT, docs, commit message). A blocking claim that isn't backed by a verified `br dep list` check is not true yet.
6. After seeding: `br list --json | jq length` (or `br stats` if available) and `br ready`. Sanity-check that `br ready` shows only the true entry point(s) (typically just the scaffolding epic, or — brownfield — whatever's next given already-closed prior work) and everything else is blocked — if more than that is ready, you likely missed a dependency edge. **Note this aggregate check can miss a single missing edge**: if the blocked issue already has *other* incoming dependencies (e.g. from an earlier epic), it will still show as correctly blocked in `br ready` even if the specific open-question edge from rule 5 was never added. `br ready` passing is not proof any one specific edge exists — only the per-edge `br dep list` check in rule 5 proves that.

## Step 7 — Ask about the Feedback subsystem's scope

**Greenfield:** before committing, ask the user explicitly (**AskUserQuestion**, don't decide silently): leave verification fully stubbed until the scaffolding issue is worked (recommended default — matches "harness infra before code infra"), or add a minimal, app-code-free tooling config now (lint/type-check/test config + one trivial passing test, no application code) so the hooks are live immediately. Either is legitimate; the point is this is a real scope fork the user should make, not you.

**Brownfield:** this question is usually already answered — the repo already has lint/type-check/test tooling (that's what Step 1's detection found). Confirm the hooks in Step 4 actually dispatch to it correctly (the smoke tests should show real, non-stubbed behavior) rather than asking the user to choose again.

## Step 8 — Commit

```bash
git add -A
git status   # review before committing -- confirm nothing unexpected is staged, and that pre-existing files were edited additively, not replaced
git commit -m "..."
```
One commit is fine (`br`'s own tracker-init commit already happened separately in step 2). Verify `git status` is clean afterward.

## Step 9 — Self-review checklist (do this before declaring done)

- [ ] No epic has another epic as `--parent` (check: `br list --json | jq '[.[] | select(.issue_type=="epic")]'` and inspect each one's parent field)
- [ ] Every requirement/feature issue has a real Behavior/Verification/State triple in its acceptance criteria, not a placeholder
- [ ] `AGENTS.md`/`CLAUDE.md`/`docs/*.md`/`README.md`/`DECISIONS.md` contain **zero** unfilled `{{TOKEN}}` placeholders: run `grep -rn '{{' . --include='*.md'` from the project root — it should return nothing
- [ ] Same files contain **zero** leftover `<!-- guidance comments -->` from the templates: run `grep -rn '<!--' . --include='*.md'` from the project root — it should return nothing (aside from any pre-existing HTML comments a brownfield repo already had before this skill touched it — check those are unrelated, not leftover template guidance)
- [ ] Both hooks are executable and were smoke-tested (step 4), not just copied
- [ ] `.beads/policy.yaml` caps `in_progress` at `hard: 1` and this was actually smoke-tested (step 2b), not just written
- [ ] `br ready` shows exactly the expected entry-point issue(s)
- [ ] For every open-question chore claimed as a hard blocker, `br dep list <blocked-issue-id>` was actually run and shows that chore's ID — not just described in prose or assumed from `br ready` looking correct
- [ ] No open-question chore exists for a question the PRD itself signals as trivial (step 6 rule 5's triviality test) — trivial defaults should be resolved directly in `DECISIONS.md`, not tracked as chores
- [ ] `br dep list <core-differentiator-epic-id>` was run and does not list the API or UI epic as a dependency (core-differentiator must block the API, never depend on it — see step 6 rule 3)
- [ ] `docs/architecture.md` §5's core-differentiator rule was either read directly from the PRD or explicitly confirmed with the user (step 1.5) — not silently inferred
- [ ] **Brownfield only:** every pre-existing file this skill touched (`README.md`, `AGENTS.md`, `CLAUDE.md`, `.claude/settings.json`, `.beads/policy.yaml`, etc.) was diffed (`git diff --stat` / `git diff <file>`) and confirmed additive — no pre-existing content was silently deleted or rewritten
- [ ] **Brownfield only:** no br issue was created for a requirement that's already fully implemented without also being marked `closed` with a pointer to the proof (step 6's audit sub-step)
- [ ] Working tree is clean (`git status`)
- [ ] If a stronger model/reviewer is available (e.g. an `advisor`-style tool), use it before declaring done — this skill was itself built after such a review caught real gaps (missing session-start checklist, a dangling doc reference, an inconsistently-resolved open question). Don't skip that check just because a checklist exists; the checklist won't catch what it wasn't written to catch.
