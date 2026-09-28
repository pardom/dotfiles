---
name: fix-bug
description: Fix a bug by reproducing it with a failing test, diagnosing the root cause from evidence, fixing the cause rather than the symptom, verifying end to end, and getting a fresh-context review.
argument-hint: "<symptom, issue link, or failing command>"
disable-model-invocation: true
---

# Fix bug

Bug: $ARGUMENTS

The hard part of a bug is finding its cause, not writing the fix. Work from
evidence, keep a record of what you've ruled out, and stop to report rather
than guess. These rules apply throughout:

- **No fix before a reproduction** observed failing for the expected reason
  (`../../policies/testing.md`).
- **Fix causes, not symptoms.** No catch-alls, retries, sleeps, widened
  tolerances, or skipped tests that make the symptom disappear.
- **Two dead ends** (hypotheses that evidence ruled out with nothing better
  left) means stop and report what you know.
- **Pausing with work in progress:** use the owner-bound hold helper in
  [verification policy](../../policies/verification.md); resume only your hold.
- **Stay in scope.** Record other bugs you find; don't fix them.

## 1. Orient

Read `docs/LESSONS.md`, `docs/CONTEXT.md`, and the spec covering the affected
behavior. Decide what the correct behavior is. If the spec doesn't say, or the
"bug" is arguably intended, ask before going further: it may be a spec gap,
not a bug.

## 2. Reproduce

1. Pin down the symptom: exact input, steps, environment, and actual vs.
   expected output. Get missing details from me rather than assuming them.
2. Reproduce it by hand through the real entry point.
3. Write an automated test that fails because of the bug, at the lowest
   level that still shows the symptom. Add an end-to-end test too if the
   symptom only appears there.
4. Run it and confirm it fails **for the reason in the bug report**, not on
   setup or an unrelated error.

If you can't reproduce it, say what you tried and what information would
help (logs, versions, data, timing), and stop.

## 3. Diagnose

1. List hypotheses for the cause, most likely first, each with the
   observation that would confirm or rule it out.
2. Test them cheaply: read the code path, add temporary instrumentation, vary
   one input at a time, shrink the failing case.
3. **Regression?** If it used to work, use `git bisect run <repro command>`
   to find the commit that introduced it.
4. Keep a short log: hypothesis → evidence → ruled in or out.
5. Stop when you can explain the full chain from cause to symptom, and the
   explanation predicts the test's failure.

Remove temporary instrumentation when you're done. For broad searches, use a
subagent so file contents don't fill this context.

## 4. Fix

- Make the smallest change that removes the cause. If the right fix is a
  larger redesign, describe it and ask before doing it.
- Look for the same flaw elsewhere (same pattern, same misuse). Fix it only
  if it's the same root cause in the same area; otherwise record it.
- Follow the policies in `../../policies/` for any code you touch.

## 5. Verify

- The reproducing test now passes, and fails again if you revert the fix.
- `.agents/check` passes. A skipped step is unverified, not passed.
- The original symptom is gone through the real entry point.
- Record required methods, results, observer, and revision/tree-bound evidence
  per the verification policy. Missing required proof blocks completion; a
  stop-hook escape or hold never proves success.

## 6. Review

Invoke the `review` skill with base `HEAD` and, as criteria, the expected
behavior, the root cause, and the reproducing test. It runs in fresh
context. Fix blocking findings, re-run step 5, and list non-blocking
findings in your report.

## 7. Record

- If this bug belongs to a plan, add follow-ups to the plan as in `build`.
- Propose a lesson if the cause could recur. Say whether a lint, test, or
  type could prevent the whole class of bug; `/learn` routes it from there.
- If the spec was unclear or wrong, propose the edit or an open question.

## 8. Report

```
## Bug: <one-line summary>
Symptom: <actual vs. expected>
Reproduction: <test name and command; failing output before the fix>
Root cause: <the chain from cause to symptom>
Ruled out: <hypotheses and the evidence against each>
Fix: <what changed and why it addresses the cause>
Evidence: <passing test, check, and end-to-end results>
Elsewhere: <same flaw found and fixed, or recorded>
Lessons: <proposed lesson and possible enforcement, or "none">
```

Don't commit unless I ask. When I do, put the root cause in the commit body.
