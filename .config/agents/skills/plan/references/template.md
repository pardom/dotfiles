# Plan: <Feature name>

Spec: [docs/specs/<feature-slug>.md](../specs/<feature-slug>.md)
ADRs: <links, or "none">

## Design

<Short summary: domain model, boundaries, core vs. shell, interfaces, reuse.
Code sketches of key types are welcome; implementation detail is not.>

## Runtime environment (when required)

<Startup/readiness, controlled fixtures and transient states, resources and
isolation, logs/observations, reset/cleanup, enabling tasks. Omit for tasks
whose proof needs no runtime setup.>

## Tasks

### T1: <walking skeleton: short name>
- **Status:** todo
- **Covers:** <PREFIX>-1
- **Goal:** <the observable behavior this task delivers>
- **Touches:** <code areas or files>
- **End-to-end check:** <how to see it working through the real entry point>
- **Depends on:** none

### T2: <short name>
- **Status:** todo
- **Covers:** <PREFIX>-2, <PREFIX>-3
- **Goal:** ...
- **Touches:** ...
- **End-to-end check:** ...
- **Depends on:** T1

## Coverage

| Example | Task | Required method | Result | Tested revision / tree | Evidence | Observer |
|---|---|---|---|---|---|---|
| <PREFIX>-1 | T1 | <command or manual checklist> | unverified | Not run | Pending | Pending |
| <PREFIX>-2 | T2 | <method> | unverified | Not run | Pending | Pending |

<!-- One row per example and required method. Evidence: expected/actual, logs
     or artifacts, relevant environment. Revision/tree: HEAD + content identity
     covering tracked and relevant untracked content. Observer: builder-reported
     or independently observed. Results: pass | fail | unverified. See the shared
     verification policy; skipped steps remain unverified. -->

## Verification dispositions

<!-- Required proof must pass or have an explicit scope decision before done.
     Record owner, reason, affected claims, receiving task when reassigned, and
     downstream work allowed despite the unknown. Optional limits remain
     unverified. Dispose every required obligation and [verify] follow-up before
     plan completion or marking the spec implemented. -->

## Risks and open questions

- <Risk or question, and how a task addresses it>

## Follow-ups

<!-- Open items that outlive a session. /build and /run-plan add them; tick
     them off when resolved. Tags: [decision] an assumption awaiting my call,
     [verify] something not yet verified (manual check, skipped tool),
     [review] a non-blocking review finding, [enforce] owned enforcement or
     environment remedy, [investigate] a cause still hypothesized. Include owner,
     destination, and closure evidence for enforceable lessons. -->

## Progress log

<!-- /build appends one line per task: date, task, status, short note. -->
