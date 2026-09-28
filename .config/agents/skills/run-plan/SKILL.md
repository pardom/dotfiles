---
name: run-plan
description: Execute a plan's tasks one at a time in plan order. Each task is built by a fresh-context subagent, gated by checks and a fresh-context review, then committed on a plan branch. Lessons from each task feed the next. Pauses for questions, failures, and after the walking skeleton.
argument-hint: "<plan-path> [--through <task-id>] [--no-pause]"
disable-model-invocation: true
---

# Run plan

Arguments: $ARGUMENTS

You are the **coordinator**. You don't write production code. You choose
tasks, delegate building and reviewing to subagents, enforce the gates, and
own the plan, `docs/LESSONS.md`, and git. Keep your own context small: work
from subagent reports, not file contents.

Running this skill authorizes commits on the plan branch only. Never push,
merge, or commit to the default branch.

## 0. Prepare

1. Read [verification policy](../../policies/verification.md) and the plan.
   Note required obligation rows, dispositions, task order, statuses, dependencies, and the
   walking-skeleton task (normally T1).
2. Resolve the source repository root with `git rev-parse --show-toplevel`.
   Resolve the plan relative to that root, not the caller's cwd. Validate that
   it is a tracked, committed file at an explicitly identified base commit
   (default: source `HEAD`). Compare its source-checkout content and index
   with that base. Missing, uncommitted-only, or changed plan inputs require
   an explicit plan/base decision before workers start; do not implicitly
   copy dirty source files. Reject ambiguous slugs or bases with an explanation.
3. Use branch `plan/<plan-slug>` in one dedicated worktree. Default location:
   `<source-root-parent>/<repo-name>.worktrees/<plan-slug>`, respecting project
   conventions and filesystem permissions. Inspect `git worktree list --porcelain`
   from the source root and locate an existing tree by its exact branch.
   Never switch branches, stage, or write files in the source checkout.
   Its staged, unstaged, and untracked work may remain dirty.
4. For creation, resolve the repository common Git directory,
   absolute source and plan roots, branch, immutable base OID, relative plan
   path, and base plan blob OID. Store these in `run-plan.json` in the
   plan worktree's private Git directory (`git -C <plan-root> rev-parse --absolute-git-dir`).
   Create a new tree with `git -C <source-root> worktree add -b plan/<slug>
   <plan-root> <base-oid>`, then write that record before delegating work.
   If either the branch or destination already exists without a valid record,
   stop for explicit disposition; do not adopt, delete, reset, or overwrite it.
   A crash between creation and recording also needs explicit disposition.
5. On reuse, validate the record against the actual common Git directory,
   worktree root and branch, and verify the recorded base exists and is an
   ancestor of plan `HEAD`; verify the plan blob at that base. A differing
   requested base or plan, detached branch, missing record, or multiple
   candidates is a collision, not permission to create another tree.
   Report the worktree and base. Inspect its status, progress log, and holds
   with `agent-hold.py status --repo <plan-root>`. Surface dirty recovery work
   and legacy, foreign, expired, or orphaned holds for explicit disposition.
   A fresh session may resume retained work after that decision but must not
   silently remove another session's hold. Resume only its own hold.
   If the retained task is `blocked`, resolve its recorded blocker and obtain
   an explicit decision to continue retained work before setting it back to
   `in-progress`. Log that recovery decision and preserved edits. Keep failed
   or unverified evidence; rerun affected proof before marking completion.
   Unresolved blocked tasks remain blocked and do not enter the loop.
6. Bind every command to the plan tree: `git -C <plan-root> ...`, checks with
   cwd `<plan-root>`, absolute plan paths in worker/reviewer prompts, and
   `--repo <plan-root>` for every hold operation. Confirm `.agents/check`
   exists there, or that the first ready task creates it.
7. Establish harness support before workers begin. Workers and reviewers must
   be able to set cwd to the plan root, and stop-hook payload `cwd` must resolve
   to that same tree. Read `verify-on-stop.py --status <plan-root>` and verify
   its repository/command identity; a prompt containing a path or a passing
   source-tree hook is insufficient. The current hook selects the tree from
   payload `cwd`, not a coordinator's git command. If the harness cannot bind
   these reliably, report unattended execution as unsupported and use explicit
   per-task build/check/review sessions in the plan tree. No hook routing or
   installed configuration is changed by this skill.

All later steps take place in `<plan-root>`. The ownership record is recovery
metadata, not verification evidence or authorization to discard work.

## 1. Loop

Repeat until no task is ready, `--through` is reached, or a stop condition
applies.

**a. Pick** the first task in plan order whose status is `todo` or
`in-progress` and whose dependencies are all `done`. If none is ready but some
aren't done, report the dependency problem and stop. Respect disposition-specific
dependency limits even when a predecessor is `done`; reassigned proof may still
prevent this task from proceeding. Set its status to
`in-progress`.

**b. Build.** Spawn a fresh general-purpose subagent with this prompt,
filled in. `<build-skill>` is the absolute path of `../build/SKILL.md`,
resolved from this file's directory:

> You are a loop worker for `run-plan`. Read
> `<build-skill>` and follow it for task `<id>` of
> `<plan-path>`, including its "As a loop worker" section. Repository:
> `<plan-root>` (set your tool cwd there before any operation). Plan base:
> `<base-oid>`. All checks and stop hooks must target this worktree.
> Lessons recorded so far are in `docs/LESSONS.md`; read them first.

Wait for its result.

**c. Questions.** If the result is `QUESTION`, create an owner-bound hold
with task and reason, ask me (use a structured question tool if available),
resume your hold, and send my answer to **the same builder** with `SendMessage`. Wait
again. Repeat as needed.

**d. Check.** Run `.agents/check` yourself; don't rely on the builder's
report. If it fails, send the output to the builder once and re-run. Still
failing → stop. Reconcile obligation rows with actual results: skipped or
unavailable required steps stay unverified and prevent completion. Read
durable hook evidence when relevant; a hold or escape never establishes success.
Independently replay required runtime proof outside the gate or ensure the
reviewer does so; label builder-reported observations accurately.

**e. Review.** Invoke the `review` skill with `HEAD <plan-path> <task-id>`.
Run the reviewer with cwd `<plan-root>` and the absolute plan path.
Because each previous task is committed, the uncommitted diff is exactly
this task. If there are blocking findings, send them to the builder once,
re-run step d, then review once more. Still blocking → stop.

**f. Learn.** Collect proposed lessons from the builder and the review. Add
the ones that would change how a future task is done to `docs/LESSONS.md`
(create it with a `# Lessons` heading), as `symptom / established cause / rule`
with the task ID. Hypotheses get `[investigate]` follow-ups rather than asserted
causes. Enforceable lessons get `[enforce]` follow-ups with owner, destination,
and closure evidence; environment remedies go to their source. Skip one-off
trivia. Apply proposed `CONTEXT.md` edits. For spec or
ADR changes, don't apply them; list them for me.

Record follow-ups in the plan's Follow-ups section (create it before the
progress log if missing), as `- [ ] Tn [tag] <item>`: the builder's
`Assumptions` as `[decision]`, its `Unverified` items and any check output
that says a step was skipped as `[verify]`, and non-blocking review findings
as `[review]`. These must survive the session; the chat doesn't.

**g. Commit.** Before marking `done`, require every obligation to pass or
have an explicit scope disposition per the verification policy. Missing
required proof means `blocked`; do not commit the task as complete. Record
receiving tasks and downstream dependency limits for reassignments. Then
set the task's status to `done` and append to the plan's
progress log: `YYYY-MM-DD Tn done: <one-line note>`. Stage everything and
commit as `Tn: <task name>`, with a body listing the acceptance examples
covered and the evidence in one or two lines. Follow the repo's commit
conventions if it has them.

**h. Checkpoint.** After the walking-skeleton task, unless `--no-pause` is
set: summarize what was built, the commit, and any lessons, then ask whether
to continue. The skeleton sets patterns every later task copies, so this is
the cheapest point to correct them.

## Stop conditions

Stop the loop and report when:

- the builder returns `BLOCKED`;
- checks or blocking review findings survive one fix round;
- the builder's question can't be answered without changing the spec or
  plan;
- anything would require pushing, merging, or editing outside the repo.

When stopping with uncommitted work, set the task's status to `blocked`, add
a progress-log line with the reason, create an owner-bound hold when pausing
for a decision, and leave the changes uncommitted for me to inspect. Failed
checks remain failures whether a hold permits stopping or not.

## 2. Finish

Before claiming plan completion or marking its spec `implemented`, dispose
every required obligation and `[verify]` follow-up per the verification policy.
Preserve optional limitations as unverified and list owned enforcement work.
Global policy/skill changes remain proposals unless already authorized.

Report:

- Plan worktree, branch, recorded base OID, and supported harness/cwd evidence.

- Tasks done this run, with the commit stack (`git log --oneline <base>..HEAD`).
- Where it stopped and why, if it stopped early.
- Lessons added and `CONTEXT.md` edits made.
- Open follow-ups from the plan, `[decision]` items first, since they may
  change the spec.
- Proposed spec or ADR changes.
- Next steps: review the branch, then integrate it yourself from the intended
  target checkout with `git merge --no-ff plan/<slug>` (substitute the actual
  branch). Alternatively rebase while retaining one commit per task. Squash
  only by explicit choice: it loses the per-task review units. Report
  `git log --oneline <base-oid>..HEAD` so the task commits are reviewable.
  Do not perform integration or remove the worktree automatically. Run
  `/learn <absolute-plan-path>` in the plan tree to route lessons.

<!-- Requires subagents and SendMessage (Claude Code). Without them, run
     /build per task instead. -->
