# <Feature name>

Status: draft | accepted | implemented | superseded
Prefix: <PREFIX>

## Outcome

<Who this is for, the problem, and how we'll know it worked. 2–4 sentences.>

## Context

<What exists today that this builds on: code areas, interfaces, related specs
and ADRs. Links, not copies.>

## Language

<New or clarified terms, also added to docs/CONTEXT.md.>

- **<Term>**: <definition>

## Behavior

<Workflows, rules, and states in domain language. Prefer short lists and a
state table over prose.>

| State | Event | Next state | Notes |
|---|---|---|---|

## Acceptance examples

### <PREFIX>-1: <short name>
- **Given** <starting state>
- **When** <action or event>
- **Then** <observable outcome>

### <PREFIX>-2: <short name>
...

## Out of scope

- <Explicitly excluded, and deferred items with a pointer to where they're tracked>

## End-to-end verification

<The concrete steps that show the feature working through the real entry
point: commands to run, screens to check, expected results.>

## Testability and constraints

<State, timing, inputs, and external dependencies that must be controlled to
demonstrate the examples. Note fixtures, completion gates for transient states,
setup costs, and policy conflicts requiring a decision. Omit irrelevant detail.>

<!-- implemented requires disposition of every required verification obligation
     and [verify] follow-up in the plan; an accepted optional limitation stays
     unverified. -->

## Open questions and assumptions

- [ ] <Question or assumption, with who decides>
