---
name: learn
description: Turn failures and surprises into durable context, and keep it lean. Captures lessons from a bug, incident, review, or finished run; routes each to where it takes effect (a check, project docs, or my global setup); and prunes lessons that are enforced, obsolete, or duplicated.
argument-hint: "[what happened | plan path | 'garden']"
disable-model-invocation: true
---

# Learn

Input: $ARGUMENTS

A lesson only helps if it's read at the moment it matters, and context that
grows without pruning stops being read. So prefer enforcement over notes, put
each lesson where the next agent will meet it, and remove what no longer
earns its place.

Use this after a `run-plan` finishes, after a bug or incident, when a
correction keeps recurring, or periodically with `garden`.

## 1. Gather

From the input, collect candidate lessons with evidence:

- **What happened** (a bug, incident, or correction I describe): find the
  symptom, then the root cause in code, tests, or history. Don't record a
  lesson whose cause you haven't established. Record hypotheses as owned
  `[investigate]` follow-ups with the observation needed to settle them; e.g.
  an exit code alone does not establish OOM.
- **A plan path:** the plan's progress log and Follow-ups, the commits on
  its branch, and lessons added during the run.
- **`garden`, or nothing:** the existing `docs/LESSONS.md` entries.

Also read `docs/LESSONS.md`, `docs/CONTEXT.md`, the project `AGENTS.md`, and
`../../AGENTS.md` so you don't duplicate what's already known.

## 2. Route

For each lesson, pick the first destination that fits:

1. **Enforce it.** If a lint rule, test, type, check step, or hook can make
   the mistake impossible or loud, propose that change. An enforced rule needs
   no note. Write lint messages as fix instructions.
2. **Fix the source.** If the cause is in the environment rather than the
   project (a shell alias, a missing tool, a misleading config), propose the
   fix there instead of a workaround note.
3. **Project knowledge**, true only of this codebase:
   - a trap or technique → `docs/LESSONS.md`
   - a domain term or rule → `docs/CONTEXT.md`
   - a design decision → an ADR
   - a requirement gap → the spec's open questions
4. **Global knowledge**, which would recur in any project:
   - a coding practice → the relevant file in `../../policies/`
   - a workflow problem → the skill that should have prevented it
   - always-relevant environment facts → `../../AGENTS.md`, only
     if removing the line would cause mistakes

Global changes affect every project and every agent, so propose them as a
diff and apply them only when I approve.

Every proposed enforcement or environment fix gets an owned follow-up in
the plan or project's durable task tracker: destination, concrete remedy,
closure evidence, and status. Use `[enforce]` for these and `[investigate]`
for unproven causes. A missing linter routes to the check/tool setup; a shell
alias routes to its environment source. A proposal alone is not enforcement.

## 3. Write

Project lessons use this form:

```
- **<Short rule-like title>.** (<source: task, incident, or date>)
  Symptom: <what was observed>
  Cause: <the established root cause>
  Rule: <what to do instead, concrete enough to act on>
```

Keep each to a few lines. A lesson without a concrete rule isn't one yet.

## 4. Prune

Go through `docs/LESSONS.md` and remove or shorten entries that are:

- **enforced** now by a lint, test, or check: delete only with closure evidence
  showing the enforcer runs; name it;
- **promoted** to an applied policy, skill, or `AGENTS.md`; or **routed** to an
  owned durable task whose destination carries the symptom/evidence and rule,
  without claiming the pending remedy is already enforced;
- **obsolete**, because the code or tool they describe is gone;
- **duplicated** or subsumed by a broader entry.

Aim to keep the file short enough to read in full before each task. If it
keeps growing, that's a sign lessons should be enforced rather than noted.

## 5. Report

- Lessons added, with where each went and why.
- Proposed enforcement and source fixes, ready to apply.
- Proposed global changes as diffs, awaiting my approval.
- Entries pruned and the reason for each.

Don't commit unless I ask.
