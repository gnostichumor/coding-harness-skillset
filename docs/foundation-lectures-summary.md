# Foundation Lectures Summary (01-04)

## Lecture 01: Strong Models Don't Mean Reliable Execution

**Core thesis:** Same prompt, same model, different harness → dramatically different outcomes. The problem is usually the harness, not the model.

**Key data:**
- SWE-bench Verified: strongest agents achieve ~50-60% pass rate
- Anthropic experiment: Opus 4.5, same prompt — bare harness = 20 min/$9 broken game; full harness = 6 hr/$200 playable game
- OpenAI: Codex in a well-harnessed repo goes from "unreliable" to "reliable"

**Failure modes:**
1. Vague requirements — agent can only guess
2. Implicit conventions not written down
3. Incomplete environment setup
4. No verification methods
5. Cross-session state loss

**Key concepts:**
- **Capability Gap**: Gap between benchmark performance and real-task performance
- **Harness**: Everything outside model weights — instructions, tools, environment, state, feedback
- **Harness-Induced Failure**: Model has capability, environment has structural defects
- **Verification Gap**: Agent's confidence vs. actual correctness
- **Diagnostic Loop**: Execute → observe failure → attribute to layer → fix → re-execute
- **Definition of Done**: Verifiable conditions (tests pass, lint clean, type checks pass)

---

## Lecture 02: What a Harness Actually Is

**Core thesis:** A harness is a system of five interacting subsystems. Every failure maps to exactly one subsystem.

**The Five Subsystems:**

| # | Subsystem | Provides | Failure when... |
|---|-----------|----------|-----------------|
| 1 | Instructions | Task spec, conventions, DoD | Requirements are vague or implicit |
| 2 | Tools | Filesystem, shell, search, git | Agent can't access what it needs |
| 3 | Environment | Dependencies, dev setup | Agent wastes context on setup errors |
| 4 | State | Cross-session continuity | Every session starts from scratch |
| 5 | Feedback | Tests, lint, verification | Agent declares victory when not done |

**Key insight:** The subsystems interact. A failure in one can cascade to others. The diagnostic loop attributes failure to the root subsystem, not the symptom.

---

## Lecture 03: Why the Repository Must Become the System of Record

**Core thesis:** The repository is the single source of truth for an agent project. Everything the agent needs — context, conventions, progress, decisions — lives in the repo, not in ephemeral context windows.

**Key patterns:**
- **AGENTS.md** — Project-level instructions (tech stack, conventions, verification commands)
- **PROGRESS.md** — Task-level progress tracking
- **DECISIONS.md** — Architecture and design decisions with rationale
- **Feature lists** — Structured task breakdowns with verification criteria

**Why repos over context:**
- Context windows are ephemeral and finite
- Repos persist across sessions, agents, and time
- Repo structure is discoverable (agent can navigate)
- Git provides version history and rollback

---

## Lecture 04: Why One Giant Instruction File Fails

**Core thesis:** A single massive instruction file (one huge AGENTS.md) fails because it's too large to fit in context, too hard to maintain, and creates conflicting signals.

**Problems with giant instruction files:**
1. **Context overflow** — Too large to fit in the model's context window
2. **Maintenance burden** — Hard to update without breaking other things
3. **Conflicting signals** — Contradictory instructions cause confusion
4. **Irrelevant noise** — Agent reads everything, even what doesn't apply

**Better approach: Layered instructions**
- **Layer 1**: AGENTS.md (root) — High-level project context, tech stack, verification
- **Layer 2**: Module-level docs — Per-module conventions and patterns
- **Layer 3**: Task-level specs — Definition of Done for specific tasks
- **Layer 4**: Runtime context — Dynamic state (PROGRESS.md, DECISIONS.md)

**Key principle:** Only load what's relevant to the current task. Don't dump everything into one file.

---

## Unified Framework: The Five Defense Layers

Every harness failure maps to one of five layers. Build defenses at each layer:

1. **Task Specification** — Clear, specific requirements with Definition of Done
2. **Context Provision** — AGENTS.md, module docs, feature lists (layered, not monolithic)
3. **Execution Environment** — Complete dev setup, dependency management
4. **Verification Feedback** — Tests, lint, type checks, executable completion criteria
5. **State Management** — Cross-session continuity via repo-based state files

## The Diagnostic Loop (Revisited)

```
1. Execute the task
2. Observe: did it succeed or fail?
3. Attribute: which subsystem layer caused the failure?
4. Fix: add or improve the defense at that layer
5. Re-execute: verify the fix works
6. Log: record the failure, layer, and fix for future reference
```

After a few rounds, the bottleneck layer becomes obvious. Focus energy there.

## Key Takeaways

1. **Don't blame the model first.** Try the diagnostic loop.
2. **Write explicit Definitions of Done.** Every task needs verifiable completion criteria.
3. **Create AGENTS.md.** It's the highest-ROI file in the project.
4. **Use layered instructions.** Not one giant file — context-appropriate layers.
5. **Build the diagnostic loop habit.** Every failure is a signal about your harness.
6. **The repo is the system of record.** State, context, and conventions live in the repo.
