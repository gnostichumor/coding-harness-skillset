---
name: state-and-scope
description: Manage agent state persistence, WIP limits, feature lists, and initialization phases. Covers Lectures 05-08 of Learn Harness Engineering.
trigger: "When agents lose context across sessions, overreach on tasks, fail to complete features, or need structured initialization."
---

# State & Scope

Manage agent state persistence, work-in-progress limits, feature list structures, and initialization phases. This skill covers Lectures 05-08 of Learn Harness Engineering.

## Core Thesis

**Agents without persistent state and scope control will fail on anything beyond trivial tasks.** Context windows are finite, and agents exhibit "context anxiety" when approaching limits — rushing to finish, skipping verification, and choosing simple over optimal solutions.

## Lecture 05: State Persistence

### The Problem

Context windows are finite. When agents approach limits, they exhibit **context anxiety**:
- Rush to finish
- Skip verification steps
- Choose simple solutions over optimal ones
- Lose track of what's been done

### The Solution: State Persistence Files

Agents need external state files that persist across sessions:

| File | Purpose |
|------|---------|
| `PROGRESS.md` | Current task progress, what's done, what's next |
| `DECISIONS.md` | Architecture and design decisions with rationale |
| Git checkpoints | Code state at key milestones |

### ACID Analogy for Agent State

| Property | Meaning for Agents |
|----------|-------------------|
| **Atomicity** | A task is either fully verified or not done |
| **Consistency** | State files match the actual code state |
| **Isolation** | WIP=1 — only one task active at a time |
| **Durability** | State persisted to files + git, not just context |

### Rebuild Cost

Good harnesses compress session rebuild time from ~15 minutes to ~3 minutes. The state files enable an agent to pick up exactly where the previous session left off.

---

## Lecture 06: Initialization Phase

### Core Insight

Initialization and implementation have **different optimization targets**. They must be separate phases.

- **Initialization**: Explore, understand, set up — optimize for context building
- **Implementation**: Execute, verify, complete — optimize for task completion

### Dedicated Initialization Shows 31% Higher Feature Completion Rates

(Anthropic data)

### Startup Readiness Checklist

Before starting implementation, verify:
- [ ] Can start (dependencies installed, environment ready)
- [ ] Can test (test commands work, can run verification)
- [ ] Can see progress (PROGRESS.md exists, git is clean)
- [ ] Can pick up next steps (feature list exists, current task is clear)

### Time Recovery

Time invested in initialization is recovered within 3-4 sessions. The upfront cost pays for itself quickly.

---

## Lecture 07: WIP Limits and Scope Control

### The Overreach Problem

Agents tend to:
1. **Overreach** — Activate too many tasks simultaneously
2. **Under-finish** — Low completion rate on activated tasks

This creates a vicious cycle: more activations → more context pressure → more failures → more activations.

### WIP=1 Rule

**Only one task active at a time.** This shows 37% higher task completion rates.

### Verified Completion Rate (VCR)

```
VCR = verified tasks / activated tasks
```

**Rule:** Block new task activations when VCR < 1.0.

### Completion Evidence

Completion evidence must be **executable**, not subjective:
- ❌ "The code looks fine"
- ✅ "curl returns 201"
- ✅ "pytest passes all tests"
- ✅ "mypy --strict shows no errors"

---

## Lecture 08: Feature Lists

### Feature Lists Are Harness Primitives

Not optional memos. Structured feature lists show **45% higher feature completion rates**.

### Triple Structure

Every feature in a feature list has three parts:

1. **Behavior** — What the feature does (user-visible)
2. **Verification** — How to prove it works (executable command)
3. **State** — What changes in the system

### State Machine

```
not_started → active → passing (terminal, irreversible)
```

**Key rule:** The harness controls state transitions, not the agent. An agent cannot mark its own work as "passing" without verification.

### Feature List Format

```markdown
## Feature List

### F-001: User Authentication
- **Behavior**: Users can log in with email/password
- **Verification**: `curl -X POST /api/login -d '{"email":"test@test.com","password":"test"}'` returns 200 with JWT
- **State**: New auth module, user table migration

### F-002: Search Endpoint
- **Behavior**: GET /api/search?q=xxx returns paginated results
- **Verification**: `pytest tests/test_search.py` passes
- **State**: New search module, index builder

### F-003: ...
```

---

## Unified Patterns

### Pattern 1: Session Handoff

When a session ends:
1. Update PROGRESS.md with current state
2. Commit work to git
3. Update feature list (mark completed features as "passing")
4. Document any decisions made in DECISIONS.md

When a new session starts:
1. Read AGENTS.md for project context
2. Read PROGRESS.md for current state
3. Read feature list for next task
4. Run initialization checklist
5. Begin implementation

### Pattern 2: WIP=1 Enforcement

The harness (not the agent) enforces WIP limits:
- Only one feature marked "active" at a time
- New features cannot be activated until the current one reaches "passing"
- VCR is monitored; if it drops below 1.0, no new activations

### Pattern 3: Initialization Phase

Before any implementation work:
1. Verify environment (dependencies, tools, test commands)
2. Read state files (PROGRESS.md, DECISIONS.md, feature list)
3. Run initialization checklist
4. Confirm next task is clear and verifiable

---

## Key Data Points

| Metric | Value |
|--------|-------|
| Context anxiety effect | Agents rush, skip verification when context is low |
| Rebuild time compression | 15 min → 3 min with good state files |
| Initialization benefit | 31% higher feature completion rates |
| WIP=1 benefit | 37% higher task completion rates |
| Feature list benefit | 45% higher feature completion rates |
| Tasks without persistent state | Failure rates spike sharply >30 min |

## Anti-Patterns

- **No state files** — Every session starts from scratch
- **No initialization phase** — Jumping straight into implementation
- **Multiple WIP** — Activating many tasks simultaneously
- **Subjective completion** — "Code looks fine" instead of executable verification
- **Agent-controlled state transitions** — Agent marks its own work as done without verification
- **Unstructured feature lists** — Free-form notes instead of triple structure

## When to Use This Skill

- Agents are losing context across sessions
- Tasks are taking too long and agents are rushing
- Completion rates are low
- You need to structure a feature list for an agent
- You're setting up initialization procedures
- You need WIP limits to prevent overreach

## Associated Projects

- **Project 03**: Multi-Session Continuity — build state persistence
- **Project 04**: Incremental Indexing — structured feature management
