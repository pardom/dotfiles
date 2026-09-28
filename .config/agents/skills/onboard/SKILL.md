---
name: onboard
description: Orient me to an unfamiliar codebase. Explains what the app is and the problem it solves, who uses it and why, the main user flows, the domain model, the architecture, and what else I should know before changing it, citing files for every claim. Read-only. Use when I'm new to a repository or ask what a project is or how it works.
argument-hint: "[path or area to focus on] [my role or first task]"
---

# Onboard

Focus: $ARGUMENTS

Build me a working mental model of this project: why it exists, who it's for,
how they use it, what it's made of, and where the traps are. Read, run
read-only commands, and report; don't edit files.

Every claim needs a source. Cite `file:line`, a doc, or a command and its
output. Mark each claim as **stated** (the project says so: docs, comments,
names, UI copy) or **inferred** (you concluded it from code), and say how sure
you are when it matters. Inferred purpose and users are drafts for me to
correct, not facts.

If I gave a focus or a first task, go deep on that area and stay shallow
elsewhere.

## 1. Survey

Start broad and cheap before reading code:

- Docs: `README`, `AGENTS.md`/`CLAUDE.md`, `docs/` (especially `CONTEXT.md`,
  specs, ADRs, `LESSONS.md`), `CONTRIBUTING`, changelogs, wikis linked from
  them.
- Shape: top-level layout, manifests and lockfiles (language, frameworks,
  key dependencies), CI config, Dockerfiles and deploy config, env examples.
- Size and history: lines per language, `git log` age, recent activity,
  contributors, and churn hotspots
  (`git log --since=1.year --name-only --format= | sort | uniq -c | sort -rn | head`).

For a large repository, sweep sections 2–5 in parallel with read-only
subagents if the harness has them, then verify their key claims yourself.

## 2. Purpose and users

- **What it is and what problem it solves.** Prefer the project's own words;
  then product copy in the UI, app store or package metadata, landing pages,
  and string resources. Say what people would do without it if you can tell.
- **Who uses it and why.** Look for distinct user types in auth roles and
  permissions, tenancy, separate apps or route trees (admin, customer,
  partner, internal tools), onboarding screens, and API consumers. Include
  machine users: other services, scheduled jobs, webhooks. For each, give
  their goal and the parts of the system they touch.

## 3. User flows

- List the entry points: screens and navigation graphs, routes, CLI commands,
  public API endpoints, consumers of queues and events, scheduled jobs.
- Pick the 3–5 flows that matter most: the core value flow, sign-up or first
  use, money or data-loss paths, and anything tied to my focus. Trace each end
  to end through the code, from trigger to UI, handler, domain logic,
  persistence, and side effects, and back to what the user sees. Name the
  files at each hop.
- If you can run the app cheaply and safely, do it and walk one flow to
  confirm the trace. Otherwise say that the flows are read from code only.

## 4. Domain model

- **Language.** The terms the project uses, each with a one-line meaning and
  where it's defined. Flag synonyms (two names for one thing) and homonyms
  (one name, different meanings in different modules).
- **Entities and relationships.** Read schemas, migrations, ORM models,
  domain types, and API contracts (OpenAPI, GraphQL, protobuf). Sketch the
  core entities with cardinalities as a small text diagram.
- **Rules and lifecycles.** Invariants and validations, and the states each
  important entity moves through, with the events that move it. Note where
  the rules live: in types, in one domain layer, or scattered across
  handlers and the database.
- **Bounded contexts**, if the project has distinct areas that use the same
  words differently or own their own data.

## 5. Architecture

- **Runtime topology.** Processes and deployables, datastores, caches, queues,
  third-party services, and how they talk. A small text diagram helps.
- **Code structure.** Modules or layers, which way dependencies point, and
  where effects (I/O, clock, network, platform APIs) happen relative to domain
  logic. Compare with `../../policies/functional-core.md` and
  report where it differs, as a fact about the codebase rather than a
  criticism.
- **Cross-cutting concerns.** Auth, configuration and secrets, error handling,
  logging and observability, feature flags, background work, i18n.
- **Build, run, test, ship.** The commands that actually work. Run the
  read-only ones (build, test, lint) if they're fast and need no secrets, and
  report what passed, what failed, and what you couldn't run. Note how
  releases happen.
- **Notable decisions.** Major ADRs or design choices visible in the code, and
  why they were made if the project says.

## 6. What else to know

Include only what's true here and would change how I work:

- **Health.** Test coverage by area and the kind of tests (unit, integration,
  end-to-end, fakes or mocks), flaky or skipped tests, TODO/FIXME clusters,
  deprecated paths still in use, dependencies that are pinned or outdated.
- **Risk.** Code that handles money, auth, personal data, migrations, or
  concurrency; churn hotspots with weak tests; places where one change
  ripples widely.
- **Conventions** that differ from my global ones in `AGENTS.md`.
- **Workflow readiness.** Whether there's a project `AGENTS.md`, an
  `.agents/check`, and `docs/CONTEXT.md`. If they're missing, say so and point
  to `/setup-project`.
- **Where to start.** For my focus or first task: which files to read first,
  and a small, safe first change that would exercise the build and tests.

## 7. Report

```
# <Project name>: onboarding

## In one paragraph
<what it is, for whom, and how it's built>

## Purpose and problem
## Users and why they use it
## User flows
## Domain model
## Architecture
## What else to know
## Where to start

## Open questions
<things only a person can answer, and inferences that need confirming>

## Sources
<docs read, commands run with results, what you couldn't verify>
```

Put the most important point first in each section. Use short lists and small
text diagrams rather than long prose, and keep the whole report readable in
about ten minutes. If one section is thin because the code doesn't say, write
that rather than padding it.

Then offer, without doing it, to save durable parts where the next agent will
find them: domain terms in `docs/CONTEXT.md`, and anything else the project's
conventions call for.
