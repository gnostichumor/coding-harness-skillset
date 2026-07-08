# Verification & Lifecycle Lectures Summary (09-12)

## Lecture 09: Why Agents Declare Victory Too Early

**Core thesis:** Agents systematically overestimate correctness (confidence calibration bias). Premature completion is the most common failure mode.

**Three-Layer Termination Check:**
1. **Self-check** — Agent's own assessment
2. **Verification** — Executable commands (`pytest`, `mypy`, `eslint`)
3. **Validation** — External confirmation (`curl`, user acceptance)

All three must pass.

---

## Lecture 10: Why End-to-End Testing Changes Results

**Core thesis:** E2E tests change agent behavior — they write code that passes system-level tests, not just unit tests.

**Testing hierarchy:**
- Unit tests → Individual functions
- Integration tests → Module interactions
- E2E tests → Full system flows

**Verification-Validation Dual Gate:**
- **Verification**: Does code work as specified? (automated tests)
- **Validation**: Does it solve the user's problem? (E2E / human review)

Both gates must pass.

---

## Lecture 11: Why Observability Belongs Inside the Harness

**Core thesis:** Observability enables diagnosis of which subsystem is causing failures.

**Two layers:**
- **Runtime**: Tool calls, context usage, errors (logs, metrics, traces)
- **Process**: Task progress, state transitions, WIP (PROGRESS.md, feature lists, git)

**Signals to monitor:**
- Context utilization → identifies context anxiety
- Tool error rate → tools subsystem issue
- VCR → feedback subsystem issue
- Session duration → environment issue

---

## Lecture 12: Why Every Session Must Leave a Clean State

**Core thesis:** Every session must leave the project in a better state than it found it.

**Cleanup loop:**
1. Commit all work to git
2. Update state files (PROGRESS.md, DECISIONS.md, feature list)
3. Verify clean state (no uncommitted changes, no broken tests)
4. Document handoff (next steps clear)

**Sprint contract**: Defines scope, DoD, and clean state expectations.

**Quality document**: Captures project standards (mypy --strict, tests, lint, docs).

---

## Unified Framework

### Three-Layer Termination
Self-check → Verification → Validation. All must pass.

### Dual Gate
Verification gate (automated tests) + Validation gate (E2E/human review). Both must pass.

### Layered Observability
Runtime (tool calls, context, errors) + Process (task progress, state, WIP).

### Clean State Protocol
Commit → Update state files → Verify clean → Document handoff.

### Sprint Contract
Define scope, DoD, and clean state before starting.

## Key Data Points

| Metric | Value |
|--------|-------|
| Premature completion | Most common failure mode |
| Confidence calibration bias | Agents overestimate correctness |
| E2E testing effect | False completion declarations drop significantly |
| Context utilization monitoring | Identifies context anxiety early |
| VCR monitoring | Predicts task completion success |
