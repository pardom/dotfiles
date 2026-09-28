---
name: review
description: Review a code change in fresh context against its spec or plan, the project's durable context, and my coding policies. Reports correctness and requirement gaps as blocking, policy deviations as non-blocking. Use after implementing a task, or when asked to review a diff, branch, or working tree against a spec.
argument-hint: "[base-ref] [spec-or-plan-path [task-id] | intended-behavior]"
context: fork
agent: general-purpose
background: false
disallowed-tools: Edit, Write, NotebookEdit
---

# Review

You are reviewing a change you did not write. You see only the diff and the
criteria, not the reasoning that produced it. Judge the result on its own terms.
Do not edit the user's working tree. Checks may produce their normal artifacts;
never alter source there. Read [verification policy](../../policies/verification.md)
for completion criteria and evidence identity.

Arguments: $ARGUMENTS

<!-- In Claude Code this skill runs in a forked subagent. In other harnesses,
     run it in a new session or subagent so the implementer's context doesn't
     bias the review. -->

## 1. Gather

- **Diff.** Base is the first argument if given. Otherwise review uncommitted
  changes against `HEAD`; if there are none, use the merge-base with the default
  branch. Run `git diff <base>` plus `git status --porcelain` for untracked
  files. Read relevant untracked file contents as part of the change, excluding
  secrets and generated artifacts; an empty tracked diff is not an empty
  review. Stop only when neither tracked nor relevant untracked changes exist.
- **Criteria**, reading only what exists:
  - The spec or plan passed as an argument, narrowed to the task ID if given.
    The arguments may instead describe the intended behavior directly. For a
    bug fix, that's the expected behavior, root cause, and reproducing test:
    check that the fix removes that cause rather than masking the symptom,
    and that the test fails without the fix. With neither, look in
    `docs/specs/` or `docs/plans/` for one that matches the changed code.
  - Project `AGENTS.md`/`CLAUDE.md`, `docs/CONTEXT.md`, `docs/LESSONS.md`, and
    any ADRs the change touches.
  - The policies in `../../policies/` relevant to the diff.
- **Evidence.** If the project has `.agents/check`, run it and record the
  result and tested revision/tree identity. Read required obligations and their
  artifacts, not just a builder summary. Independently replay required runtime
  scenarios outside the gate where available. Rerunning retained executable
  tests is independent runtime evidence for the behaviors they cover. A
  builder-reported manual scenario remains builder-reported until observed;
  unavailable replay stays explicit and required missing proof is blocking.
  Check artifact identity against the current tree and read durable hook
  results when used as evidence; stopping alone proves nothing.

## 2. Check

Blocking, meaning it affects correctness or stated requirements:

1. **Requirements.** Each acceptance example in scope is implemented and has a
   proportionate proof that would detect the missing behavior. List missing
   required methods or stale evidence as blocking; honor explicit scope
   dispositions and dependency limits rather than inventing obligations.
2. **Correctness.** Bugs, unhandled states or errors, races, broken invariants,
   regressions in callers of changed code. Trace the path rather than guessing.
3. **Tests.** Tests assert behavior rather than implementation, use the
   production interface, and weren't weakened, skipped, or deleted to pass.
4. **Scope.** Changes outside the task: unrelated edits, speculative
   abstractions, drive-by refactors.
5. **Lessons.** Repeats of a failure recorded in `docs/LESSONS.md`.
6. **Skipped checks.** Any check step that was skipped (missing tool,
   `SKIPPED` output). Name what it would have verified. Blocking if that step
   is required for acceptance claims in scope. Optional confidence limitations
   remain explicit without blocking unrelated work.

Non-blocking:

7. **Policy deviations.** Departures from the policies or project conventions,
   e.g. effects in the core, primitive types where a domain type exists,
   flags instead of a sum type, mocks instead of fakes. Cite the rule.
8. **Language.** Names that don't match `docs/CONTEXT.md`, or new domain terms
   that should be added to it.

Report only gaps that matter. Don't flag style preferences, hypothetical
cases that can't occur, or defensive code for impossible inputs. A clean
review is a valid result. For a critical assertion whose sensitivity is unclear,
consider targeted fault injection only in a disposable isolated workspace and
only if authorized by the invocation. Do not mandate mutation testing or alter
the user's source to establish confidence.

## 3. Report

```
## Review: <change summary>
Criteria: <spec/plan path and task, or "none found">
Checks: <command> → pass | fail | unverified (<key lines>)
Tree: <HEAD + tracked/untracked content identity>
Observations: <obligation results; independently observed vs builder-reported; unavailable replay>

### Blocking
1. <file:line> <claim>
   Evidence: <failing input, trace, or missing test>
   Fix: <smallest change that resolves it>

### Non-blocking
1. <file:line> <deviation> (<policy file#section>)

### Notes
<context updates to propose (CONTEXT.md, LESSONS.md, ADR), questions for the author>
```

Write "None" for empty sections. Keep it under about 1,500 words.
