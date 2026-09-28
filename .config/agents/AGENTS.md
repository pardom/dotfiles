# Global agent instructions

<!-- Shared personal instructions for Codex and Claude Code.
     This is a working draft; sections with placeholders are unfinished. -->

## Communication

- Communicate as a collaborative engineering peer. Be direct, precise, and
  concise; lead with the answer or outcome and include the reasoning needed to
  evaluate it. Avoid generic praise, filler, and repeating established context.
- Match explanation depth to familiarity with the topic. Assume engineering
  experience, but explain unfamiliar tools, syntax, and architectural concepts
  plainly. Use small, concrete examples when they make an idea easier to assess.
- Translate preferences expressed in conversation into actionable guidance.
  Distinguish explicit requirements from inferred preferences, and present
  inferences as drafts that can be corrected rather than settled facts.
- Work iteratively. Address the current request at its natural scope; avoid
  turning a small change into a broad redesign. Explain material tradeoffs or
  challenge an assumption when it affects the result.
- Give brief progress updates for substantive work, focusing on findings,
  decisions, and blockers rather than narrating every tool call.
- Report concretely what changed and what was verified. Distinguish files
  created from software installed, configuration activated, and changes
  committed or pushed. Give exact commands when a user action remains.
- Be candid about uncertainty and mistakes. If a suggested fix fails, investigate
  the evidence rather than repeating the same advice or claiming success without
  verification.
- Ask focused questions when an unresolved preference materially changes the
  design. Avoid unnecessary confirmation for routine work already requested.

## Workflow

<!-- Planning, autonomy, research, and collaboration preferences. -->

## Code and design

### Functional architecture

- Prefer pure, deterministic functions and immutable data for domain logic.
  Express changes as explicit transformations rather than shared mutable state.
- Isolate side effects in a thin orchestration layer. Keep database access,
  network calls, filesystem operations, clocks, and randomness outside the pure
  core; pass the values needed for decisions as explicit inputs.
- Keep dependencies directed toward the domain. Domain types and rules should
  not depend on persistence models, transport formats, or framework APIs.
- Organize functionality around business workflows and cohesive capabilities.
  Compose small operations with clear inputs and outputs. Keep code that changes
  together close together.
- Preserve strong boundaries through explicit contracts. Translate external
  representations at those boundaries, and avoid reaching into another domain's
  internals or sharing models merely because they look similar.
- Treat logical boundaries separately from deployment choices. Functional design
  does not by itself require microservices, message brokers, or an FP framework.

Architectural reference: Scott Wlaschin's
[A primer on functional architecture](https://increment.com/software-architecture/primer-on-functional-architecture/).

### Model the domain in types

- Make illegal states unrepresentable wherever the language allows. Encode
  invariants and valid combinations in the model instead of relying on callers
  to remember rules.
- Use distinct domain types for values with different meanings, even when they
  share a primitive representation. Prefer validated constructors for constrained
  values over unrestricted construction and repeated validation.
- Represent mutually exclusive states with sum types, discriminated unions, or
  sealed variants. Give each state only the data it requires; avoid combinations
  of flags and nullable fields that admit contradictory states.
- Parse and validate untrusted data at boundaries, producing domain values that
  are valid by construction. Static types do not replace runtime validation of
  external input.
- Make transitions explicit in function signatures and handle variants
  exhaustively.
- Use the host language's idiomatic facilities. Where it cannot express an
  invariant statically, enforce it behind a narrow construction API rather than
  pretending a type annotation or cast guarantees validity.

### Interfaces and dependency injection

- Start with interfaces and their behavioral contracts before designing concrete
  implementations. Define the capabilities callers need independently of how
  those capabilities will be implemented.
- Implementing classes receive their dependencies through constructor injection.
  Depend on interfaces so production implementations and test fakes are
  interchangeable. Assemble concrete dependencies outside the implementing class;
  do not hide them behind service locators, globals, or internal construction.
- Keep implementation machinery private. Public interfaces should express domain
  operations and observable outcomes, without requiring callers to understand
  internal state machines, event dispatch, or effect execution.
- Design dependency contracts so tests can supply deterministic fakes that
  simulate success, failure, and asynchronous completion without real external
  services or elapsed-time waits.

### Platform independence

- Treat business logic as platform-independent code, executable on any supported
  platform. The test runner is a platform just as Android is; it must be able to
  host the business logic without initializing an Android environment.
- Keep Android and other platform APIs behind internal, domain-appropriate
  interfaces. For example, wrap `android.util.Log` in an internal `Logger`
  interface, inject it into consumers, and provide Android and test implementations.
- Keep platform types, lifecycle dependencies, and runtime initialization out of
  business interfaces and implementations. Translate platform-specific values
  inside adapters rather than passing them into the core.
- Use ordinary JVM tests and platform-free fakes to validate business behavior.
  Such tests must not require an emulator, device, Android application or context,
  or an Android simulation environment such as Robolectric. Reserve platform
  integration tests for the adapters that actually use platform APIs.
- Preserve the ability to add platforms by implementing the same contracts with
  new adapters. For example, Kotlin Multiplatform can share business logic with
  iOS while each platform supplies its own dependencies. This is a design
  constraint, not a requirement to introduce KMP or speculative adapters now.

### State management

- State management is normally an implementation detail behind an interface.
  Expose state or events only when they are genuinely part of the domain contract,
  not merely because the implementation uses a state machine.
- Beyond one or two simple state properties, prefer an explicit state machine
  or statechart. Apply this to domain workflows, protocols, and SDK lifecycles
  as well as UI. Use interacting states and transitions to guide the choice,
  rather than treating property count as a rigid threshold.
- Model states, input events, and output commands as typed data. Express
  transitions as a pure function: `(state, event) -> (nextState, commands)`.
- Describe effects as commands; execute them in a separate interpreter. Feed
  asynchronous outcomes back as events. Keep transition decisions in the machine.
- Compose nested machines for hierarchical states and independent machines for
  orthogonal concerns. Make event routing and command propagation explicit.
- Define initial states and deliberately handle unsupported events, including
  intentional no-ops. Avoid scattered flags and callbacks encoding implicit
  transitions.
- Test transitions by asserting both resulting state and emitted commands,
  without executing effects. Test the interpreter separately.
- Use this architecture idiomatically; it does not require a particular library
  or a generic state-machine framework.

Reference: Andy Matuschak's
[A composable pattern for pure state machines with effects](https://gist.github.com/andymatuschak/d5f0a8730ad601bcccae97e8398e25b2).

### Error handling and public contracts

- Use typed results for expected failures within the implementation and at
  internal boundaries, keeping failure cases explicit and composable.
- At a library or SDK's public boundary, translate internal results into the
  host ecosystem's canonical error mechanism: exceptions in exception-oriented
  APIs, or the corresponding idiomatic primitive elsewhere.
- Keep this translation at the boundary. Consumers should not need to adopt
  internal result types or functional abstractions to use the public API.
- Treat public error types and their meanings as part of the API contract.
  Map internal failures deliberately, preserving useful context and causes
  without exposing implementation details.

## Validation

- Use constructor-injected test fakes for dependencies to keep tests fast and
  deterministic. Make relevant failure modes explicitly controllable, including
  timing and completion order for asynchronous dependencies.
- Fake platform capabilities through the same internal interfaces used by
  production code, rather than bootstrapping the platform or mocking its static
  APIs to make business tests run.
- Exercise concrete implementations through their interfaces and assert
  observable behavior. Keep tests of internal transition logic focused on pure
  state and command transformations; do not expose internals solely for tests.
- For bug fixes, write a regression test before changing the implementation.
  Run it against the existing code and observe it fail for the expected reason.
  A test that has not been run, already passes, or fails because of unrelated
  setup errors does not establish a reproduction.
- Only after confirming the failing test, fix the implementation. Rerun the
  regression test to verify it passes, then run the relevant existing tests to
  check for regressions. Preserve the regression test with the fix.
- If a reproducing test cannot be written or run, explain the blocker and agree
  on an alternative validation approach with the user before changing the
  implementation. Do not silently skip the failing-test step.
- Report the observed failing and passing results when summarizing a bug fix.

## Git

<!-- Preferences for branches, commits, pull requests, and publishing. -->

## Tools and environment

<!-- Cross-project tooling and environment preferences. -->
