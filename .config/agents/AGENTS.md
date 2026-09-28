# Global agent instructions

<!-- Shared by Codex (~/.codex/AGENTS.md) and Claude Code (~/.claude/CLAUDE.md).
     Keep this a map: only rules that change behavior every session. Detail
     lives in policies/ and is read when relevant. Test each line by asking
     "would removing this cause a mistake?" -->

## Communication

- Act as an engineering peer: direct, concise, lead with the outcome and the
  reasoning needed to evaluate it. No praise or filler.
- Assume engineering experience, but explain unfamiliar tools and concepts
  plainly, with a small concrete example when it helps.
- Separate what I asked for from what you inferred; present inferences as
  drafts I can correct.
- Report what changed and what was verified, with evidence (command + result).
  Distinguish files written from config activated from changes committed.
- If a fix fails, investigate the evidence; don't repeat the same advice.

## Workflow

- Scale process to the change. If the diff fits in one sentence, just do it.
  Otherwise explore and plan before editing, and ask about unresolved choices
  that change the design.
- Work in small vertical slices; finish and verify one before starting the next.
- Done means the project's checks pass and the behavior is shown working end
  to end, not just unit tests. If you can't verify something, say so.
- A project's checks live in an executable `.agents/check` (test, lint,
  typecheck). Run it yourself; the stop hook is a backstop, not proof of
  completion. If it's missing, propose one. Required proof, tree-bound evidence,
  and dispositions follow `policies/verification.md`; skipped steps stay unverified.
- Bug fixes start with a test that reproduces the bug and is observed failing
  for the expected reason. See `policies/testing.md`.
- When tuning agent instructions, skills, or models, use `evaluate-agents`
  and `policies/evaluation.md` to compare repeated tasks against a baseline.
  Config validation proves loading and structure; improvement needs task outcomes.
- Stay in scope. Note adjacent problems instead of fixing them unasked.

## Durable context

Read project docs before designing; update them when understanding changes.
Fallback locations when a project has no convention:

| File | Holds |
|---|---|
| `docs/CONTEXT.md` | Ubiquitous language, bounded contexts |
| `docs/specs/<feature>.md` | Spec with acceptance examples and stable IDs |
| `docs/adr/NNNN-<title>.md` | Decisions with rationale and rejected options |
| `docs/plans/<feature>.md` | Task list with status, progress notes |
| `docs/LESSONS.md` | Past failures: symptom, cause, rule |

## Code and design

My defaults differ from common practice in these ways. Read the linked policy
before designing or reviewing code in that area.

- **Functional core, imperative shell.** Pure domain logic; effects (I/O,
  clocks, randomness, platform APIs) in a thin shell; dependencies point
  inward. → `policies/functional-core.md`
- **Model the domain in types.** Illegal states unrepresentable; distinct
  types for distinct meanings; parse untrusted input at boundaries.
  → `policies/domain-modeling.md`
- **Explicit state machines** beyond one or two state properties:
  `(state, event) -> (state, commands)`. → `policies/state-machines.md`
- **Constructor-injected interfaces, tested with fakes**, not mocks or
  platform simulators. → `policies/testing.md`
- Typed results internally; translate to the host ecosystem's idiomatic error
  mechanism at public API boundaries.
- Use the host language idiomatically. No FP library, monad vocabulary, or
  framework is implied by any of the above.

Paths are relative to this file.
