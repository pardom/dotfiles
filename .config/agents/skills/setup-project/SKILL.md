---
name: setup-project
description: Prepare a new or existing repository for the agent workflow: a short project AGENTS.md, a strict .agents/check run by a pre-push hook, an architecture lint where the design has boundaries, and the docs/ entry points. Additive; never restructures existing code.
argument-hint: "[what the project is, for a new one]"
disable-model-invocation: true
---

# Set up project

Project: $ARGUMENTS

Give the agents working here what they can't infer: how to verify work, what
the boundaries are, and where durable context lives. Keep every file short.
In an existing project, add to its conventions rather than replacing them.

## 1. Inspect

- Is it a git repository? If not, propose `git init` before anything else;
  hooks, reviews, and plans depend on it.
- Can this session do what setup needs? Setup writes `.git/` and `.agents/`
  and may fetch dependencies, which sandboxes often block unless I approve.
  If one of these is blocked and you can't ask me for approval, stop before
  writing any files. Tell me what was blocked and how to unblock it. Codex
  starts a folder that has no git repo and no trust entry this way, without
  offering to trust it: I should run `git init` there myself, restart Codex,
  and accept the trust prompt, or switch to a mode that asks for approval.
  Don't work around it, and don't record the session's limits in project
  files; they aren't facts about the project.
- Language, build tool, package manager, and test, lint, typecheck, and
  format commands. Look in manifests, CI config, Makefiles, and READMEs, and
  run the commands to see which actually work.
- Existing agent files (`AGENTS.md`, `CLAUDE.md`, `.cursor/`, etc.), docs,
  ADRs, and structure.

For a new project, ask only what you can't decide from the description:
language, runtime, and anything that constrains tooling. Recommend defaults
that match my policies.

## 2. Project AGENTS.md

Write `AGENTS.md` at the repo root, or update the existing one. Aim for under
60 lines, containing only what an agent can't work out from the code:

- one or two sentences on what the project is;
- commands: build, run, test, `.agents/check`, with any required setup;
- layout: where the core, shell, and tests live;
- project conventions that differ from my global ones;
- pointers to `docs/` files.

Then make Claude Code read the same file: if there's no `CLAUDE.md`, create
one containing only `@AGENTS.md`. If one exists, add that line to it.

## 3. `.agents/check`

Write an executable `.agents/check` that is the executable gate for project checks. Runtime acceptance proof
outside it remains required when the task calls for it; see
[verification policy](../../policies/verification.md). The check:

- runs tests, lint, typecheck, format check, and the architecture lint,
  whichever apply;
- runs from any working directory (`cd` to the repo root first);
- **fails when a required tool is missing**, with an install hint. Don't
  write "skip if not installed" (`../../policies/testing.md`);
- runs every step and exits non-zero if any failed. A passing step prints
  only `✓ <step>`; a failing one prints `✗ <step>` and its output; test
  runners stop at the first failure (`../../policies/testing.md`). Use `SKIPPED: <step> — <reason>` consistently if a genuine
  environment limit prevents a step. Required skips stay unverified and
  prevent completion; missing required tools fail rather than skip;
- stays fast enough to run before each stop. If it takes more than about a
  minute, say so and suggest a faster subset.

Then prove it works as a gate: run it and see it pass; add a deliberately
failing assertion and see it fail; remove the assertion and see it pass
again. Report all three.

Then run it from git: add a pre-push hook that runs `.agents/check`, so
pushes are checked even outside agent sessions.

- If the project already uses a hook manager (Husky, lefthook, pre-commit),
  add the check to its pre-push stage.
- Otherwise commit an executable `.githooks/pre-push` containing
  `exec "$(git rev-parse --show-toplevel)/.agents/check"`, and run
  `git config core.hooksPath .githooks`. That setting doesn't travel with
  the repo, so list it under setup in `AGENTS.md`. If `.git/hooks/` already
  has active hooks, ask before switching, since `core.hooksPath` disables them.

Prove the hook gates too: `git hook run pre-push` fails while the deliberate
failing assertion is in place.

When stable nonsecret environment identity can be defined, optionally add
executable `.agents/check-environment` returning it for hook cache validity.
Without this helper the hook reruns checks. Never hash secrets or arbitrary
machine environment. Route missing tools or ineffective enforcement to an
owned follow-up with destination and closure evidence; do not call them fixed
until the check demonstrably runs.

## 4. Architecture lint

If the project has, or will have, a functional core and imperative shell or
other boundaries (`../../policies/functional-core.md`):

- write the dependency rules down: core must not import shell, adapters,
  frameworks, or platform APIs; contexts don't reach into each other;
- enforce them with the ecosystem's tool (Konsist or ArchUnit on the JVM,
  dependency-cruiser for TS/JS, import-linter for Python) or a small script.
  Write failure messages as fix instructions;
- wire it into `.agents/check`.

In a new project, create the layout and the rule together. In an existing
project that already violates the rule, don't fix the violations: report
them and propose a baseline (allow existing violations, block new ones) or a
plan to fix them.

## 5. Docs

- Create `docs/CONTEXT.md` with a short heading and any domain terms you can
  already identify. Leave other `docs/` entries (specs, plans, ADRs,
  `LESSONS.md`) to the skills that create them; don't add empty folders.
- Record any decision made here that is hard to reverse, such as language
  or test framework, as an ADR.

## 6. Report

- Files created or changed, a line each.
- Gate evidence: the check passing, failing on purpose, and passing again,
  and the pre-push hook failing on purpose.
- Architecture rules in force, and any existing violations.
- Open questions, and the next step: `/spec <first feature>`.

Don't commit unless I ask.
