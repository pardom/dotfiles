# Trial: <task ID / config label / trial number>

Status: <scheduled | completed | timeout | infrastructure failure>
Task and grader identity: <revision/content manifest>
Config identity: <instructions, skills, harness/version, model, tools, permissions>
Environment identity: <nonsecret versions and fixtures>
Starting and resulting tree identity: <commit + content manifest>
Artifacts: <prompt, trace, final report, diff, grader logs>

## Independent results

| Claim | Result (pass/fail/unverified) | Command/observer | Expected / actual | Evidence |
|---|---|---|---|---|
| <claim ID> | unverified | <grader> | <expected / not run> | <artifact> |

Acceptance: <pass only when all required claims pass; otherwise fail/unverified>
Retained regressions: <count, affected behavior, evidence; or unknown>
Unsupported completion: <count, quoted claim and contradicting/missing evidence>
Human intervention: <count, actions, active correction minutes; or unknown>
Resources: <wall time, tokens, cost; mark missing fields unknown>
Post-correction acceptance: <separate result, if corrections were made>
Infrastructure failures/exclusions: <reason and effect on comparison>
Observed failure and proposed follow-up case: <facts, or none>
