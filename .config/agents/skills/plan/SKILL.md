---
name: plan
description: Turn a spec into a design and an ordered list of vertical-slice tasks, each small enough for one /build session, written to docs/plans/ with status tracking. Records significant decisions as ADRs.
argument-hint: "<spec-path>"
disable-model-invocation: true
---

# Plan

Spec: $ARGUMENTS

Decide how the spec will be realized, and break the work into tasks a fresh
`/build` session can each complete and verify. This skill writes no
production code.

## 1. Orient

Read the spec in full, then `docs/CONTEXT.md`, related ADRs,
`docs/LESSONS.md`, and the policies in `../../policies/`. Explore
the affected code, using a subagent for broad exploration: entry points,
existing types and interfaces to reuse, test setup, and the project's check
commands.

If the spec has unresolved open questions that affect the design, stop and
ask before planning around them.

## 2. Design

Keep this brief. It's the shared understanding the tasks build on, not a
document for its own sake. Cover only what the spec needs:

- **Domain model.** Types, states, and transitions, applying
  `../../policies/domain-modeling.md` and `../../policies/state-machines.md`.
- **Boundaries.** Which bounded context owns what, and where external data is
  parsed into domain values.
- **Core and shell.** Pure decisions vs. effects; the interfaces the shell
  depends on (`../../policies/functional-core.md`).
- **Reuse.** Existing code to build on rather than duplicate.
- **Testability.** State, timing, inputs, and dependencies that must be
  controllable for acceptance proof; enabling seams and their costs. Surface
  unavailable methods and policy conflicts for an explicit scope decision.
  Keep pure-domain tests independent of live services and platforms.

For each decision that is hard to reverse (a new boundary, dependency,
persistence shape, or public API), sketch two options, pick one, and write an
ADR to `docs/adr/NNNN-<title>.md`: context, decision, options considered,
consequences.

## 3. Slice

Break the work into **vertical slices**. Each task delivers observable
behavior through the real entry point, not a horizontal layer like "add the
repository".

- **T1 is a walking skeleton:** the thinnest end-to-end path through every
  layer the feature needs, covering one acceptance example.
- Each later task adds behavior and covers one or more acceptance examples.
- Each task fits one `/build` session: a few files and a handful of tests.
  Split anything larger.
- Order tasks by dependency, then by risk; do the uncertain things early.
- Every acceptance example is covered by at least one task. Check this with
  the coverage table. Read [verification policy](../../policies/verification.md):
  one row per example and required method, initially `unverified`. Choose
  commands or manual checklists that prove the claim; multiple rows only when
  multiple methods are necessary. Include enabling tasks and runtime setup
  when proof needs them. Required proof is part of the task, not deferred by
  calling its limitation accepted.

Add enabling tasks only when a slice needs them:

- **Checks.** If the repo has no `.agents/check` or project `AGENTS.md`,
  recommend running `/setup-project` before building. If I'd rather not, the
  first task creates a strict `.agents/check` (tests, lint, typecheck).
- **Architecture lint.** If the design introduces or relies on a dependency
  rule (domain must not import infrastructure, contexts don't reach into each
  other) and nothing enforces it, add a task that sets up a dependency lint
  with fix-it error messages and wires it into `.agents/check`. See the
  Enforcement section of `../../policies/functional-core.md`.

## 4. Write

Write `docs/plans/<feature-slug>.md` using
[references/template.md](references/template.md). Every task starts with
`Status: todo`. Statuses are `todo | in-progress | done | blocked`; `/build`
updates them and appends to the progress log. Apply the verification policy
completion/disposition rules before `done`, plan completion, or marking a spec
`implemented`. Preserve explicit ownership and dependency limits on reassignments.

## 5. Confirm

Show me the design summary, the ADRs, and the task list with coverage. Ask
whether to adjust the slicing or the order before calling the plan final.

## 6. Report

- Plan path and ADR paths.
- Task count, with any examples whose coverage is weak.
- Risks and open questions.
- Next step: `/build docs/plans/<feature-slug>.md T1`, in a fresh session.
