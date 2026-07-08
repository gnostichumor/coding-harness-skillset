---
name: harness-foundation
description: Build a production-grade agent harness from scratch using the five-subsystem model, diagnostic loop, and Definition of Done. Covers Lectures 01-04 of Learn Harness Engineering.
trigger: "When building, auditing, or debugging an agent harness; when agent tasks fail despite a capable model; when context is insufficient or verification is missing."
---

# Harness Foundation

Build a production-grade agent harness from scratch. This skill covers the five-subsystem model, the diagnostic loop methodology, and the foundational patterns from Lectures 01-04 of Learn Harness Engineering.

## Core Thesis

**When things fail, don't swap the model first — check the harness.** The gap between benchmark performance and real-world performance is almost always a harness problem, not a model problem.

## The Five Subsystems

Every agent harness has five subsystems. Every failure maps to exactly one:

| # | Subsystem | What it provides | Failure mode |
|---|-----------|-----------------|--------------|
| 1 | **Instructions** | Task specification, conventions, Definition of Done | Vague requirements, implicit rules |
| 2 | **Tools** | Filesystem, shell, search, git, MCP | Agent can't access what it needs |
| 3 | **Environment** | Dependencies, dev setup, runtime config | Agent wastes context on `pip install` errors |
| 4 | **State** | Cross-session continuity, progress tracking | Every session starts from scratch |
| 5 | **Feedback** | Tests, lint, verification commands | Agent declares victory when not done |

## The Diagnostic Loop

The core methodology of harness engineering:

```
Execute → Observe failure → Attribute to specific layer → Fix that layer → Re-execute
```

**Rules:**
- Never say "the model isn't good enough." Attribute every failure to a specific subsystem layer.
- After each failure, log: task, outcome (success/fail), which layer caused the failure.
- After a few rounds, the bottleneck layer becomes obvious — focus energy there.
- The diagnostic loop is iterative: fix, re-test, observe, refine.

## Definition of Done

Every task needs an explicit, verifiable Definition of Done. Without one, the agent invents its own (which is always wrong).

```markdown
## Definition of Done
- [ ] New endpoint GET /api/search?q=xxx
- [ ] Supports pagination, default 20 items
- [ ] Results include highlighted snippets
- [ ] All new code passes pytest
- [ ] Type checking passes (mypy --strict)
- [ ] No lint errors
```

**Key principles:**
- Conditions must be verifiable by command, not by feeling.
- Place DoD in the task specification or an AGENTS.md file.
- One DoD per task — don't make agents juggle multiple completion criteria.

## AGENTS.md — The Highest-ROI File

Place an `AGENTS.md` file in the repo root. It tells the agent about:
- Tech stack and architecture
- Architectural conventions (naming, patterns, folder structure)
- Verification commands (test, lint, type-check)
- Definition of Done format
- Any implicit rules the team follows

**One AGENTS.md file is often more effective than upgrading to a more expensive model.**

## The Million-Line Experiment (OpenAI, 2025)

Three engineers built ~1M lines of code using only Codex. Their pattern:
1. Break large goals into small building blocks (design → code → review → test)
2. Each block has a clear Definition of Done
3. Use the diagnostic loop: every failure reveals a harness gap
4. After 5 months, 1,500 PRs, 3.5 per person per day

## Key Data Points

| Metric | Value |
|--------|-------|
| SWE-bench Verified pass rate (strongest agents) | ~50-60% |
| Same model, bare vs. full harness (Anthropic) | 20 min/$9 (broken) vs. 6 hr/$200 (playable) |
| OpenAI's claim for Codex in well-harnessed repo | "Unreliable" → "Reliable" |
| Failure rate spike for agents without persistent state | Tasks >30 min |
| "Context anxiety" — agents rush when context runs low | Skip verification, choose simple over optimal |

## Capability Gap

The huge gulf between model performance on benchmarks and performance on real tasks. A 50-60% pass rate on SWE-bench Verified means nearly half of real issues go unresolved. Real tasks have:
- Vague specs
- No existing tests
- Implicit business rules scattered across the codebase
- No clear Definition of Done

## Harness-Induced Failure

The model has sufficient capability, but the execution environment has structural defects. Proven by Anthropic's controlled experiment: same model, same prompt, different harness → dramatically different outcomes.

## Verification Gap

The gap between the agent's confidence in its output and actual correctness. The agent says "I'm done" when it's not. This is the most common failure mode.

## Anti-Patterns

- **"The model isn't good enough"** — First reaction to failure. Usually wrong.
- **Implicit conventions** — Rules that exist only in your head or a Slack message.
- **No verification commands** — Agent writes code, looks at it, decides it seems fine.
- **Cross-session state loss** — Every new session starts from scratch.
- **Context anxiety** — Agent rushes to finish when context is running low.
- **Vague task specs** — "Add a search feature" means almost nothing.

## When to Use This Skill

- You're building a new agent harness from scratch.
- An agent task failed and you need to diagnose why.
- You're auditing an existing harness for gaps.
- You need to write an AGENTS.md or Definition of Done.
- You're setting up verification commands for a project.

## Associated Projects

- **Project 01**: Prompt-Only vs. Rules-First — measure the difference a minimal harness makes
- **Project 02**: Agent-Readable Workspace — structure a repo for agent consumption
