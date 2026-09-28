---
name: spec
description: Turn a feature idea into a self-contained spec by interviewing me about the hard parts, then write it to docs/specs/ with acceptance examples and an end-to-end verification step.
argument-hint: "<brief feature description>"
disable-model-invocation: true
---

# Spec

Feature: $ARGUMENTS

Produce a spec precise enough that a fresh session can plan and build from it
without this conversation. Specify behavior, not implementation. This skill
writes no code.

## 1. Orient

Read what exists: project `AGENTS.md`/`CLAUDE.md`, `docs/CONTEXT.md`,
related specs in `docs/specs/`, related ADRs, and `docs/LESSONS.md`. Explore
the code this feature would touch, using a subagent for broad exploration.
Come to the interview knowing what the code already does, so you don't ask
me things you can look up.

## 2. Interview

Ask about the hard parts I may not have considered, not the obvious ones.
Use a structured question tool (e.g. `AskUserQuestion`) when available:
1–4 related questions per round, concrete options, and your recommendation
first with the reason.

Work through these, skipping what is already settled:

- **Outcome.** Who it's for, the problem it solves, how we'd know it worked.
- **Language.** Terms that are new, ambiguous, or used differently than in
  `docs/CONTEXT.md`. Pin each one down.
- **Workflows.** Triggers, steps, and outcomes, in business terms.
- **Rules and invariants.** What must always or never hold.
- **States.** The lifecycle of the main things, and which transitions are
  allowed.
- **Edge cases and failures.** Invalid input, concurrency, partial failure,
  retries, timing, permissions, empty and large cases.
- **Scope.** What is explicitly out, and what is deferred.
- **Verification.** How to show it working end to end through the real entry
  point. Identify state, timing, inputs, and dependencies that must be
  controllable, especially fixed backends and brief busy/loading states.
  Prefer controlled fixtures or completion gates over racing screenshots.
  Surface setup costs, inaccessible dependencies, and testing-policy conflicts
  as decisions; do not assume every project needs a live service/platform test.

Turn answers into concrete examples as you go and check them with me: "So
given X, when Y, then Z?" Examples expose disagreements that abstract rules
hide.

Stop when no remaining question would change the spec. Record anything still
open as an explicit assumption or open question rather than guessing.

## 3. Write

Write `docs/specs/<feature-slug>.md` using
[references/template.md](references/template.md). Follow the project's own
spec convention instead if it has one.

- Acceptance examples are Given/When/Then with stable IDs (`<PREFIX>-1`, …).
  Each one is observable and testable. IDs never get renumbered; retire them
  instead.
- Requirements use the domain language. Name code areas and interfaces only
  in the Context section.
- Keep it as short as the feature allows.

## 4. Update the glossary

Add new or clarified terms to `docs/CONTEXT.md`, creating it if needed:
one line each, with the bounded context if relevant. Show me the additions.

## 5. Report

- Spec path, plus a summary of the outcome and the number of examples.
- Open questions and assumptions that need my decision.
- Next step: `/plan docs/specs/<feature-slug>.md`, ideally in a fresh
  session.
