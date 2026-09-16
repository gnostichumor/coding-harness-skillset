# Coding Harness Skillset

Claude Code skills for building production-grade agent harnesses, based on the
Learn Harness Engineering curriculum: the five-subsystem model, state/WIP/
feature-list control, verification gates and session lifecycle, and a
one-shot skill that bootstraps a full harness from a PRD.

## Skills

| Skill | Covers |
|---|---|
| `harness-foundation` | Five-subsystem model, diagnostic loop, Definition of Done (Lectures 01-04) |
| `state-and-scope` | State persistence, WIP=1, feature lists, initialization phase (Lectures 05-08) |
| `verification-and-lifecycle` | Three-layer termination, verification-validation dual gate, clean-state protocol (Lectures 09-12) |
| `harness-projects` | The six progressive reference projects from the curriculum |
| `harness-bootstrap` | One-shot harness creation (tech-stack decision, `AGENTS.md`/`CLAUDE.md`, `bd`-seeded issues, verification hooks) from a PRD, composing the four skills above |

`docs/` contains the source lecture summaries each methodology skill is
distilled from.

## Install

As a Claude Code plugin, directly from this repo:

```
/plugin marketplace add gnostichumor/coding-harness-skillset
/plugin install coding-harness-skillset@coding-harness-skillset-marketplace
```

## License

MIT — see [LICENSE](LICENSE).
