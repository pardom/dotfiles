# Evaluating agent configurations

Use when assessing changes to instructions, skills, orchestration, or models.
Routine code edits still follow [verification.md](verification.md); don't run
a benchmark for every task. Validate config structure and discovery separately
from claims about improved behavior.

## Tasks and independent grading

Start with a small pilot of real tasks, then grow toward 10–20 representative
cases: bug fixes, features, refactors, investigations, and config changes.
Include past failures and a few tasks the baseline already handles well.
Each task pins its repository, starting commit, exact prompt, environment,
time budget, acceptance criteria, and independently maintained graders.
Never benchmark an unfinished working tree by resetting the user's checkout.

Freeze criteria before running the candidate. Grade observable behavior and
retained regressions, using public interfaces and real entry points. The
evaluated agent can write tests, but those tests and its completion report
cannot be the sole acceptance proof. Keep private grader inputs and expected
answers outside the agent's workspace; public requirements remain visible.
Don't demand a particular implementation unless the requirement demands it.

Run graders against the initial state to establish sensitivity: the targeted
bug or missing feature must fail for the expected reason, while retained
regression checks pass. For investigation tasks, use factual references and
a human rubric instead of a test that presupposes code changes.

## Comparable trials

Compare baseline and candidate on identical tasks from fresh isolated copies
of the pinned start. Change one factor at a time. Record model, harness version,
effective instructions and skill contents (including loaded user-level config),
tools, permissions, and environment. A source commit alone is insufficient
when plugins auto-update or configuration lives outside the repo.

Start with three trials per task per configuration when practical; declare
trial count and resource limits before running. Alternate run order to reduce
time-dependent effects. Run sequentially unless parallel execution is requested.
Don't change models implicitly or grant permissions beyond the original task.
Verify that the target harness supports isolated config before launching it;
otherwise report the comparison as confounded rather than assuming isolation.

Save prompt, config manifest, trace, resulting diff and tree identity, grader
commands/logs, final report, duration, and available usage/cost for every trial.
Record human interventions and active correction minutes. Missing measurements
stay unknown, not zero. Keep artifacts outside evaluated source inputs.

## Scores and interpretation

Keep these measures separate:

| Measure | Definition |
|---|---|
| Acceptance | All required independent acceptance checks pass |
| Regression | Previously passing retained behavior now fails |
| Unsupported completion | Agent claims completion or a successful check contradicted by evidence, or with no supporting evidence |
| Human correction | Active minutes and interventions needed to reach acceptance |
| Resources | Wall time, tokens, and cost where observable |

Use `pass`, `fail`, or `unverified` per obligation. Infrastructure failures
stay distinct from agent failures; include them in counts and explain exclusions.
Timeouts are unsuccessful bounded trials, not silent exclusions. Report success
counts over all scheduled trials, with unverified counts alongside them.
Don't combine scores into a weighted number that conceals regressions.

Use deterministic graders where possible. Human rubrics handle usefulness,
scope, design, and factual investigations. Blind reviewers to config labels
where practical. If using an LLM judge, pin its model and rubric and calibrate
against human judgments; its verdict is not proof that executable behavior works.

Show per-task baseline/candidate results as well as aggregate counts. A small
pilot supports a provisional decision, not a universal quality claim. Keep
regression cases stable and use fresh holdout tasks before generalizing. Add
observed failures to the suite; version tasks and graders when criteria change.
