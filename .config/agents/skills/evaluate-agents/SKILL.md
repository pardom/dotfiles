---
name: evaluate-agents
description: Create or run repeatable evaluations of coding-agent instructions, skills, or models against a baseline using real repository tasks and independent acceptance checks. Use to measure setup changes, not to verify an ordinary code edit.
---

# Evaluate agents

Read [evaluation policy](../../policies/evaluation.md). Deliver a reproducible
comparison with trial evidence, or a prepared suite with explicit unrun items
when execution isn't available. Never invent performance results.

## Prepare

Inspect the requested config, project checks, and existing task artifacts.
Identify the comparison question and candidate change. Preserve a content
manifest of the baseline before changing it. If no historical baseline exists,
reconstruct it from the recorded revision where possible and disclose limits.

Use the project's eval convention. Otherwise store curated cases under
`evals/agents/tasks/` and put trial artifacts in an ignored
`evals/agents/runs/` directory. Use [task template](references/task.md) and
[trial template](references/trial.md); replace placeholders only with observed
facts. Suggest real cases from specs, bug reports, and history. Don't fabricate
10–20 realistic tasks just to fill a quota; begin with a few useful cases.

Keep independent graders outside the evaluated workspace. Establish their
baseline sensitivity and record the result. Prepare setup, run, grade, and
cleanup commands using the actual harness's documented interface. Prefer an
existing eval runner; add a project-specific runner only when repeated execution
justifies it. A generic guessed CLI invocation is not a working harness.

## Run and grade

Set the task/trial count and limits before launching paid model runs. Ordinary
authorized local trials can proceed; if budget or execution scope is missing,
prepare everything reviewable before asking for it. Never substitute a different
model without the user's direction. Don't launch nested agents or parallel
agent work unless requested.

Run each trial in a fresh isolated repository and fresh session with the pinned
config. Capture the trace and outcome before independently grading it. A smoke
test of config loading is useful, but isn't a completed agent-task trial.
Use the trial template to record all required evidence and unknowns. Human
correction after the initial run gets its own result; preserve the initial score.

## Report

Give the baseline/candidate configuration identities, task suite revision,
trial counts, and per-task acceptance, regression, unsupported-completion,
correction, and resource results. Explain unverified and excluded trials.
Recommend keep, revise, or gather more evidence based on observed tradeoffs.
Link the saved cases and trial artifacts. Separate config written, config
discovered/loaded, and improvement measured. Don't activate a candidate merely
because a pilot scored better unless activation is within the user's request.
