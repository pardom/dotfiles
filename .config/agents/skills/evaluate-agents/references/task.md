# Task: <stable ID and title>

Kind: <bug | feature | refactor | investigation | config>
Source: <real issue, spec, or past failure>
Repository and starting commit: <repository, full SHA>
Environment: <runtime/tool versions, fixtures, setup and readiness commands>
Limits: <wall time, turns or spend where supported>

## Exact prompt

<What the agent receives, including public requirements; same for both setups.>

## Independent acceptance

| Claim | Grader command or human rubric | Expected outcome | Initial-state observation |
|---|---|---|---|
| <claim ID> | <check maintained outside evaluated workspace> | <observable result> | <expected failure or applicable baseline> |

Retained regression command and observed initial result: <command + log>
Grader version/content identity: <manifest>
Rubric for scope/design/factual quality, if relevant: <criteria>

## Trial setup

Isolation and config selection: <verified mechanism, effective config manifest>
Fresh workspace setup: <commands>
Agent launch and trace capture: <commands>
Grade and capture final tree/diff: <commands>
Cleanup: <owned disposable paths; retain evidence>
Grader visibility: <private inputs kept outside agent workspace>
Dependencies or limitations: <facts, or none>
