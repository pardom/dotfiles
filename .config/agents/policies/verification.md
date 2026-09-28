# Verification and completion

Use this contract when planning, building, coordinating, or reviewing work.
Verification methods follow acceptance claims; do not require every test level
for every task. Hook paths below are relative to this file; resolve them to
absolute paths before running them.

Verification proves a particular change. Evaluation compares the reliability
of agent configurations across repeated tasks; see [evaluation.md](evaluation.md).
Neither a successful stop hook nor an agent's own completion report is an
independent acceptance grader.

## Obligations and evidence

Record one coverage row per acceptance example and required method. Results
are `pass`, `fail`, or `unverified`; skipped or unavailable steps stay
`unverified`, even when the enclosing command exits zero. Optional confidence
checks may remain follow-ups without blocking unrelated work.

Evidence includes the command or manual checklist, expected and actual result,
artifact/log locations, relevant environment, observer (builder-reported or
independently observed), and tested revision/tree. Record `HEAD` and a content
identity for tracked modifications and relevant untracked files. A status list
alone is not a content identity. Where available,
`python3 ../hooks/verify-on-stop.py --identity <repo>` produces
a HEAD/content fingerprint without running the gate or recording a pass. A reproducible manifest of path/content hashes,
including deletions, is sufficient; exclude secrets and generated noise. Bind
artifacts to that identity and rerun affected checks after material changes.
Recording evidence in a plan changes a whole-tree fingerprint. Document those
evidence-only edits and retain a reproducible manifest of the tested source
inputs when needed; do not call an old hook-cache fingerprint a current match.

A task is `done` only when required obligations pass or an explicit scope
decision removes or reassigns them. Otherwise use `blocked` with a reason.
Reassignment names the receiving task and downstream work allowed despite the
unknown. Every disposition names its owner, reason, and affected acceptance
claims. An accepted optional limitation never changes `unverified` to `pass`.
Before plan completion or a spec becomes `implemented`, give every required
obligation and `[verify]` follow-up a disposition: observed completion, explicit
scope reduction, reassignment, or accepted optional limitation.

## Stop-hook evidence and holds

The stop hook controls stopping; it does not certify task completion. Read its
latest durable result with
`python3 ../hooks/verify-on-stop.py --status <repo>`.
Records live at `${XDG_STATE_HOME:-~/.local/state}/agents/verify-on-stop/`
under `<sha256-of-repo-root-first16>.result.json`. Check identity, result, time,
command, exit status, and log before relying on it; a missing gate, hold,
skipped step, failure escape, or stale identity never establishes success.

A project may provide executable `.agents/check-environment` returning a
stable nonsecret environment identity for caching. Without it checks rerun;
do not collect arbitrary environment variables or secrets.

For an authorized pause use `python3 ../hooks/agent-hold.py`
with `create --owner <session_id> --task <task> --reason <reason>`; inspect
with `status`, and resume with `resume --owner <session_id>`. Use the actual
harness session ID; do not invent an owner. If the harness does not expose it,
pause without a marker and report verification honestly; never fabricate an
owner to suppress the hook. Commands default to the current
repository; pass `--repo <repo>` when needed. The JSON v1 hold
records owner, task, reason, and UTC creation time and expires after 24 hours.
Only its owner resumes it. Legacy, foreign, expired, or orphaned holds need an
explicit disposition and do not silently suppress checks. Never delete another
session's marker or use a hold to present failing work as complete.
