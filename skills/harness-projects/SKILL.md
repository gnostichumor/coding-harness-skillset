---
name: harness-projects
description: Execute the six progressive projects from Learn Harness Engineering. Covers project structure, agent-readable workspaces, multi-session continuity, incremental indexing, grounded QA, and runtime observability.
when_to_use: "When executing the Learn Harness Engineering projects, building progressive harness capabilities, or implementing the full harness architecture."
---

# Harness Projects

Execute the six progressive projects from Learn Harness Engineering. Each project builds on the previous ones, creating a complete production-grade agent harness.

## Project 01: Prompt-Only vs. Rules-First

**Goal:** Measure the difference a minimal harness makes.

**Setup:**
- Two identical codebases
- Same prompt for both
- One has AGENTS.md with conventions, verification commands, and Definition of Done
- The other has no harness

**Measure:**
- Time to first working solution
- Number of iterations to completion
- Verification pass rate on first attempt
- Agent confidence vs. actual correctness

**Expected outcome:** Rules-first approach completes faster with higher quality, even with the same model.

---

## Project 02: Agent-Readable Workspace

**Goal:** Structure a repository for optimal agent consumption.

**Components:**
1. **AGENTS.md** — Project-level instructions
   - Tech stack and architecture
   - Architectural conventions (naming, patterns, folder structure)
   - Verification commands (test, lint, type-check)
   - Definition of Done format

2. **Module-level docs** — Per-module conventions
   - API conventions
   - Error handling patterns
   - Testing patterns

3. **Feature list** — Structured task breakdown
   - Triple structure (Behavior, Verification, State)
   - State machine (not_started → active → passing)

4. **State files** — Cross-session continuity
   - PROGRESS.md
   - DECISIONS.md

**Measure:**
- Agent comprehension (can it explain the architecture?)
- Task completion rate
- Time to first successful task

---

## Project 03: Multi-Session Continuity

**Goal:** Build state persistence so agents can work across sessions.

**Components:**
1. **State files** — PROGRESS.md, DECISIONS.md, feature list
2. **Git checkpoints** — Commit at key milestones
3. **Initialization phase** — Startup readiness checklist
4. **Session handoff protocol** — End-of-session cleanup

**Key patterns:**
- WIP=1 enforcement
- Verified Completion Rate (VCR) monitoring
- Three-layer termination check
- Clean state protocol

**Measure:**
- Feature completion rate across sessions
- Rebuild time (time to pick up where left off)
- VCR over time

---

## Project 04: Incremental Indexing

**Goal:** Implement structured feature management with incremental indexing.

**Components:**
1. **Feature list with triple structure**
   - Behavior, Verification, State for each feature
   - State machine enforcement

2. **WIP limits**
   - Only one active feature at a time
   - VCR monitoring

3. **Initialization phase**
   - Startup readiness checklist
   - Context building before implementation

4. **Progress tracking**
   - PROGRESS.md updates
   - Git commit messages
   - Session handoff documentation

**Measure:**
- Feature completion rate (target: 45%+ improvement)
- Task completion rate (target: 37%+ improvement with WIP=1)
- Time to completion per feature

---

## Project 05: Grounded QA Verification

**Goal:** Implement verification gates and E2E testing.

**Components:**
1. **Three-layer termination check**
   - Self-check (agent assessment)
   - Verification (executable commands)
   - Validation (E2E tests, external confirmation)

2. **Verification-Validation dual gate**
   - Verification gate: Automated tests
   - Validation gate: E2E tests or human review

3. **E2E test suite**
   - Unit tests → Integration tests → E2E tests
   - Critical path coverage

4. **Quality standards document**
   - `mypy --strict`
   - Test coverage requirements
   - Lint rules
   - Documentation requirements

**Measure:**
- Premature completion rate (target: significant reduction)
- False positive rate (agent says done when not done)
- Verification pass rate on first attempt

---

## Project 06: Runtime Observability and Debugging

**Goal:** Implement observability layers for runtime and process monitoring.

**Components:**
1. **Runtime observability**
   - Tool call logging
   - Context utilization tracking
   - Error rate monitoring
   - Time-per-task metrics

2. **Process observability**
   - Feature state transitions
   - VCR tracking
   - WIP count monitoring
   - Session duration tracking

3. **Diagnostic dashboards**
   - Which subsystem is failing?
   - Context anxiety detection
   - Bottleneck identification

4. **Alerting**
   - VCR drops below threshold
   - Context utilization exceeds threshold
   - Tool error rate spikes
   - Session duration exceeds expected

**Measure:**
- Time to diagnose failures
- False completion declarations
- Agent performance over time (degradation detection)

---

## Progressive Architecture

The six projects build a complete harness:

```
Project 01: Measure the gap (baseline)
    ↓
Project 02: Build the foundation (AGENTS.md, workspace structure)
    ↓
Project 03: Add state persistence (cross-session continuity)
    ↓
Project 04: Add scope control (WIP limits, feature lists)
    ↓
Project 05: Add verification gates (E2E testing, termination checks)
    ↓
Project 06: Add observability (runtime + process monitoring)
```

Each project adds a layer of defense against harness-induced failures.

## Key Metrics Across All Projects

| Metric | Target | Measurement |
|--------|--------|-------------|
| Feature completion rate | 45%+ improvement | verified / activated |
| Task completion rate | 37%+ improvement | WIP=1 enforcement |
| Premature completion | Significant reduction | Three-layer termination |
| Rebuild time | 15 min → 3 min | State file compression |
| Initialization benefit | 31%+ improvement | Dedicated init phase |
| Context anxiety | Detected early | Context utilization monitoring |

## Anti-Patterns to Avoid

- **Blaming the model first** — Always try the diagnostic loop
- **Implicit conventions** — Write everything down
- **No verification** — Agent can't verify its own work
- **No state persistence** — Every session from scratch
- **No WIP limits** — Agent overreach
- **No E2E tests** — Only unit tests
- **No observability** — Can't diagnose failures
- **Messy session endings** — No clean state protocol

## When to Use This Skill

- You're executing the Learn Harness Engineering projects
- You're building a progressive harness architecture
- You need to implement all six projects in sequence
- You want to measure harness effectiveness

## Associated Lectures

- Foundation: Lectures 01-04
- State & Scope: Lectures 05-08
- Verification & Lifecycle: Lectures 09-12
