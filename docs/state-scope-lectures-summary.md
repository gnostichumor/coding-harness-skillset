# State & Scope Lectures Summary (05-08)

## Lecture 05: Why Long-Running Tasks Lose Continuity

**Core thesis:** Context windows are finite. Agents approaching context limits exhibit "context anxiety" — rushing to finish, skipping verification, and choosing simple over optimal solutions.

**Solution:** External state persistence files (PROGRESS.md, DECISIONS.md, git checkpoints) enable cross-session continuity.

**ACID Analogy:**
- **Atomicity**: Task is fully verified or not done
- **Consistency**: State files match actual code state
- **Isolation**: WIP=1 — one task at a time
- **Durability**: State persisted to files + git

**Rebuild cost:** Good harnesses compress from 15 min to 3 min.

---

## Lecture 06: Why Initialization Needs Its Own Phase

**Core thesis:** Initialization and implementation have different optimization targets and must be separate phases.

**Key data:** Dedicated initialization shows 31% higher feature completion rates (Anthropic).

**Startup Readiness Checklist:**
- Can start (dependencies, environment)
- Can test (verification commands work)
- Can see progress (PROGRESS.md, git)
- Can pick up next steps (feature list, current task clear)

**Time recovery:** Initialization cost recovered within 3-4 sessions.

---

## Lecture 07: Why Agents Overreach and Under-Finish

**Core thesis:** Agents activate too many tasks simultaneously (overreach) and have low completion rates (under-finish), creating a vicious cycle.

**Solution:** WIP=1 shows 37% higher task completion rates.

**Verified Completion Rate (VCR):**
```
VCR = verified tasks / activated tasks
Block new activations when VCR < 1.0
```

**Completion evidence must be executable:**
- ❌ "Code looks fine"
- ✅ "curl returns 201" / "pytest passes" / "mypy --strict clean"

---

## Lecture 08: Why Feature Lists Are Harness Primitives

**Core thesis:** Feature lists are not optional memos — they are harness primitives that show 45% higher feature completion rates.

**Triple structure per feature:**
1. **Behavior** — What it does (user-visible)
2. **Verification** — How to prove it works (executable command)
3. **State** — What changes in the system

**State machine:** `not_started → active → passing` (terminal, irreversible)

**Key rule:** Harness controls state transitions, not the agent.

---

## Unified Framework

### Session Handoff Pattern
1. End: Update PROGRESS.md → Commit → Update feature list → Document decisions
2. Start: Read AGENTS.md → Read PROGRESS.md → Read feature list → Init checklist → Implement

### WIP=1 Enforcement
- Only one "active" feature at a time
- New features blocked until current reaches "passing"
- VCR monitored

### Initialization Phase
1. Verify environment
2. Read state files
3. Run initialization checklist
4. Confirm next task is clear and verifiable

## Key Data Points

| Metric | Value |
|--------|-------|
| Rebuild time compression | 15 min → 3 min |
| Initialization benefit | +31% feature completion |
| WIP=1 benefit | +37% task completion |
| Feature list benefit | +45% feature completion |
| State loss failure spike | Tasks >30 min |
