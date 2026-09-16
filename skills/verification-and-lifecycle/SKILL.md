---
name: verification-and-lifecycle
description: Implement verification gates, observability layers, session lifecycle management, and clean state protocols. Covers Lectures 09-12 of Learn Harness Engineering.
when_to_use: "When agents declare victory prematurely, lack verification feedback, need observability, or leave messy state between sessions."
---

# Verification & Lifecycle

Implement verification gates, runtime observability, session lifecycle management, and clean state protocols. This skill covers Lectures 09-12 of Learn Harness Engineering.

## Core Thesis

**Agents without verification gates and clean state protocols will accumulate errors and degrade over time.** The verification-validation dual gate and the cleanup loop are essential for sustained agent performance.

## Lecture 09: Why Agents Declare Victory Too Early

### Premature Completion

Agents declare tasks done when they're not. This is the most common failure mode.

### Confidence Calibration Bias

Agents systematically overestimate the correctness of their output. They feel confident even when verification would fail.

### Three-Layer Termination Check

Every task should have three layers of termination criteria:

| Layer | What it checks | Example |
|-------|---------------|---------|
| **1. Self-check** | Agent's own assessment | "Code compiles, tests pass locally" |
| **2. Verification** | Executable commands | `pytest`, `mypy --strict`, `eslint` |
| **3. Validation** | External confirmation | `curl` endpoint, user acceptance |

**Rule:** A task is only done when all three layers pass.

### Termination Criteria Format

```markdown
## Termination Criteria
1. Self-check: Code compiles, no local test failures
2. Verification: `pytest tests/ -v` passes all tests
3. Validation: `curl -X GET http://localhost:8000/api/health` returns 200
```

---

## Lecture 10: Why End-to-End Testing Changes Results

### E2E Testing Hierarchy

Not all tests are equal. Structure testing in layers:

| Layer | Scope | Speed | Value |
|-------|-------|-------|-------|
| **Unit tests** | Individual functions | Fast | Catch logic errors |
| **Integration tests** | Module interactions | Medium | Catch interface mismatches |
| **E2E tests** | Full system flows | Slow | Catch real-world failures |

### The E2E Effect

Adding E2E tests to a harness changes agent behavior:
- Agents write code that passes E2E, not just unit tests
- Agents consider system-level implications
- False completion declarations drop significantly

### Verification-Validation Dual Gate

| Gate | Purpose | Who passes it |
|------|---------|---------------|
| **Verification** | Does the code work as specified? | Automated tests |
| **Validation** | Does it solve the user's problem? | E2E tests / human review |

Both gates must pass for a task to be complete.

---

## Lecture 11: Why Observability Belongs Inside the Harness

### Two Layers of Observability

| Layer | What it observes | Tools |
|-------|-----------------|-------|
| **Runtime** | Tool calls, context usage, errors | Logs, metrics, traces |
| **Process** | Task progress, state transitions, WIP | PROGRESS.md, feature lists, git |

### Runtime Feedback Signals

- **Context utilization** — How much of the context window is being used?
- **Tool call patterns** — What tools is the agent calling most?
- **Error rates** — How often do tool calls fail?
- **Time per task** — How long does each task take?

### Process Feedback Signals

- **Feature state transitions** — How many features moved to "passing"?
- **VCR (Verified Completion Rate)** — verified / activated
- **WIP count** — How many tasks active simultaneously?
- **Session duration** — How long before state loss?

### Component Boundary Defects

Observability helps identify which subsystem is causing failures:
- High tool error rate → Tools subsystem issue
- High context utilization → Instructions/State issue
- Low VCR → Feedback subsystem issue
- Long session duration → Environment issue

---

## Lecture 12: Why Every Session Must Leave a Clean State

### Session Integrity

Every session must leave the project in a better state than it found it. This is the **clean state protocol**.

### The Cleanup Loop

At the end of every session:

1. **Commit** — All work committed to git with clear messages
2. **Update state files** — PROGRESS.md, DECISIONS.md, feature list
3. **Verify clean state** — No uncommitted changes, no broken tests
4. **Document handoff** — Next steps documented for the next session

### Clean State Checklist

- [ ] All work committed to git
- [ ] PROGRESS.md updated with current state
- [ ] Feature list updated (completed features marked "passing")
- [ ] DECISIONS.md updated with any new decisions
- [ ] No uncommitted changes
- [ ] No broken tests
- [ ] Next session's starting point is clear

### Sprint Contract

A sprint contract defines the scope and commitments for a session:

```markdown
## Sprint Contract
- **Session**: 2024-01-15
- **Goal**: Complete F-003 (Search Endpoint)
- **Scope**: Implement search module, add tests, update docs
- **Definition of Done**: 
  - GET /api/search?q=xxx returns paginated results
  - pytest passes all tests
  - Documentation updated
- **Clean State**: All work committed, PROGRESS.md updated
```

### Quality Document

A quality document captures the standard for the project:

```markdown
## Quality Standards
- All code passes `mypy --strict`
- All new code has tests (unit + integration)
- E2E tests cover critical paths
- No lint errors
- Documentation updated for all changes
```

---

## Unified Patterns

### Pattern 1: Three-Layer Termination

Every task has three layers of completion criteria:
1. Self-check (agent assessment)
2. Verification (executable commands)
3. Validation (external confirmation)

All three must pass.

### Pattern 2: Verification-Validation Dual Gate

- **Verification gate**: Automated tests pass
- **Validation gate**: E2E tests or human review confirms
- Both must pass for task completion

### Pattern 3: Layered Observability

- **Runtime layer**: Tool calls, context, errors
- **Process layer**: Task progress, state, WIP
- Use both to diagnose failures

### Pattern 4: Clean State Protocol

End of every session:
1. Commit work
2. Update state files
3. Verify clean state
4. Document handoff

### Pattern 5: Sprint Contract

Define scope, DoD, and clean state expectations before starting.

---

## Key Data Points

| Metric | Value |
|--------|-------|
| Premature completion | Most common failure mode |
| Confidence calibration bias | Agents overestimate correctness |
| E2E testing effect | False completion declarations drop significantly |
| Context utilization monitoring | Identifies context anxiety early |
| VCR monitoring | Predicts task completion success |

## Anti-Patterns

- **No termination criteria** — Agent decides when it's done
- **Subjective completion** — "Code looks fine" instead of executable verification
- **No E2E tests** — Only unit tests, missing system-level validation
- **No observability** — Can't diagnose which subsystem is failing
- **Messy session endings** — Uncommitted changes, outdated state files
- **No sprint contracts** — Unclear scope and expectations

## When to Use This Skill

- Agents are declaring tasks done prematurely
- You need to set up verification gates
- You want to add observability to your harness
- Sessions are leaving messy state
- You need clean state protocols
- You're setting up sprint contracts

## Associated Projects

- **Project 05**: Grounded QA Verification — build verification gates
- **Project 06**: Runtime Observability and Debugging — implement observability
