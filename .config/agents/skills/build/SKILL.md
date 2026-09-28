---
name: build
description: Implement one task end to end, test-first, verify it, and get it reviewed in fresh context. Takes a task description, or a plan path and task ID.
argument-hint: "<task description> | <plan-path> <task-id>"
disable-model-invocation: true
---

# Build

Task: $ARGUMENTS

Take one task from intent to verified, reviewed change. These rules apply
throughout:

- **One task.** Note adjacent problems; don't fix them.
- **Stop and ask** when the spec contradicts the code, a requirement is
  ambiguous, or a design decision arises that the spec, ADRs, and policies
  don't settle. For an authorized pause use the owner-bound hold helper in
  [verification policy](../../policies/verification.md); resume only your hold.
  Use it only to ask, never to get past failing checks.
- **Never weaken, skip, or delete a test to get green.** If a test seems wrong,
  say why and ask.
- **Two failed attempts at the same problem** means stepping back: report what
  you tried and what the evidence says before trying a third approach.

## 1. Orient

Read only what exists: project `AGENTS.md`/`CLAUDE.md`, `docs/CONTEXT.md`, the
spec and plan for this task, related ADRs, and `docs/LESSONS.md`. Read the
policies in `../../policies/` that apply to the code you'll touch.
Explore the code the task touches. For broad exploration, use a subagent so
file contents don't fill this context.

Find the check command: `.agents/check` in the repo root. If it doesn't exist,
find the project's test, lint, and typecheck commands and propose an
`.agents/check` script that runs them. Create it once I agree. The stop hook
attempts this script before stopping; it does not establish completion.
Read [verification policy](../../policies/verification.md) for obligations,
tree-bound evidence, durable hook results, and completion dispositions.

## 2. Define done

State the acceptance examples for this task as Given/When/Then, taken from the
spec where one exists, by ID. Without a spec, draft 1–3 examples and confirm
them with me if there is any real ambiguity.

Record required verification methods for each example in the coverage table
(or a compact task-local table without a plan), initially `unverified`.
Identify controllable state, timing, inputs, dependencies, and runtime setup.
Surface unavailable methods or policy conflicts before implementation.

Name the end-to-end check: how you will show the behavior working through the
real entry point (CLI run, app screen, API call), not only through unit tests.

## 3. Design

Skip this step if the change fits in one sentence. Otherwise state briefly,
in the conversation:

- New or changed domain types and states (`../../policies/domain-modeling.md`),
  and state machines (`../../policies/state-machines.md`) where they apply.
- Interfaces and where the pure core ends and the shell begins
  (`../../policies/functional-core.md`).
- The files you'll change.

If this introduces a decision worth recording (new boundary, dependency, or
pattern), draft an ADR in `docs/adr/` and say so.

## 4. Implement test-first

For each acceptance example, then each lower-level invariant it needs:

1. Write the test. Run it and see it **fail for the expected reason**.
2. Write the minimal code to pass. Run it and see it pass.
3. Refactor while green.

Use fakes through production interfaces (`../../policies/testing.md`). For a bug,
the first test reproduces it.

## 5. Verify

- Run `.agents/check`; fix everything it reports.
- Run the end-to-end check from step 2.
- Update every obligation with result and tree-bound evidence per the verification
  policy. Missing required proof blocks completion; optional limits stay explicit.
- Read the durable hook result when relevant; never infer success from stopping.

## 6. Review

Skip this step as a loop worker; the coordinator runs the review.

Invoke the `review` skill with the base ref, spec or plan path, and task ID.
It runs in fresh context. If your harness can't fork it, ask me to run
`/review` in a new session.

- Fix every **blocking** finding, re-run step 5, and run `review` once more if
  the fixes were substantial.
- Don't act on **non-blocking** findings on your own. List them in your report.

## 7. Record

- Plan: apply the verification completion rule before marking `done`; otherwise
  mark `blocked` and record why. Add a one-line progress note.
- Follow-ups: add to the plan's Follow-ups section (create it before the
  progress log if missing), as `- [ ] Tn [tag] <item>`:
  - `[decision]` any assumption you made instead of asking;
  - `[verify]` anything not verified, including skipped check steps and
    manual checks still owed;
  - `[review]` non-blocking review findings.
  A note in the progress log or a commit message doesn't count; nobody acts
  on those.
- Spec: if understanding changed, propose the edit rather than silently
  diverging.
- If something surprised you (a wrong assumption, a trap, a failure that cost
  time), propose an entry for `docs/LESSONS.md` or a term for
  `docs/CONTEXT.md`.

## 8. Report

- What changed, by file, in a sentence each.
- Evidence: test, check, and end-to-end results.
- Review: blocking findings fixed; non-blocking findings for me to decide on.
- Open questions and proposed context updates.

Don't commit unless I ask.

## As a loop worker

When `run-plan` gives you a task, follow everything above with these changes:

- **Questions:** you can't ask me directly. When step 1's stop-and-ask rule
  applies, end your turn with a `QUESTION` result (below). Your answer will
  arrive as a message, and you continue from where you stopped. Don't write
  the hold marker; the coordinator manages it.
- **Skip** step 6 (review). Don't update the plan, `docs/LESSONS.md`, or git:
  the coordinator owns those.
- **Return DONE only** when the verification completion rule is met. Missing
  required proof returns BLOCKED; optional limits may accompany DONE.
- **Return exactly one** of these:

```
RESULT: DONE
Task: <id>
Changed: <file — one sentence each>
Evidence: <obligation rows: example, required method, pass/fail/unverified, HEAD + tree identity, commands/checklists, expected/actual, artifacts, environment, observer>
Dispositions: <scope decisions with owner, reason, claims, receiving task and dependency limits, or "none">
Lessons: <proposed LESSONS.md entries as symptom / cause / rule, or "none">
Context: <proposed CONTEXT.md, spec, or ADR edits, or "none">
Assumptions: <decisions you made instead of asking, or "none">
Unverified: <skipped check steps, manual checks still owed, or "none">
Notes: <anything else the coordinator or I should know>
```

```
RESULT: QUESTION
Task: <id>
Question: <one decision, with options and your recommendation first>
State: <what's done, what's in progress, whether tests are red>
```

```
RESULT: BLOCKED
Task: <id>
Reason: <what stops you, with evidence and what you tried>
State: <what's done, what's left uncommitted>
```
