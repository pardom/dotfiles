# Testing

Drive behavior test-first: a meaningful failing test, the minimal change to
pass it, then refactor. Tests assert observable behavior through interfaces,
using constructor-injected fakes.

## Example: fake over mock

Before: a mock couples the test to call sequences and can't simulate
realistic failures or ordering.

```kotlin
val api = mockk<PaymentApi>()
every { api.charge(any(), any()) } returns ChargeResult.Ok
service.checkout(cart)
verify { api.charge(cart.customerId, cart.total) }
```

After: a fake implements the same interface, with controllable failures and
completion.

```kotlin
class FakePaymentApi : PaymentApi {
    val charges = mutableListOf<Charge>()
    var nextResult: ChargeResult = ChargeResult.Ok
    var gate: CompletableDeferred<Unit>? = null // set to hold a charge in flight

    override suspend fun charge(customer: CustomerId, amount: Money): ChargeResult {
        gate?.await()
        charges += Charge(customer, amount)
        return nextResult
    }
}

@Test fun `declined payment leaves the order unpaid`() = runTest {
    val payments = FakePaymentApi().apply { nextResult = ChargeResult.Declined }
    val checkout = Checkout(payments, InMemoryOrders())

    val result = checkout.submit(cart)

    assertEquals(CheckoutResult.PaymentDeclined, result)
}
```

## Rules

- Prefer fakes through the production interface over mocks. Make failure
  modes, timing, and completion order controllable in fast domain tests.
  Keep those tests free of real services and elapsed-time waits.
- Fake platform capabilities through internal interfaces for domain tests;
  don't mock static APIs (see `functional-core.md`). Deliberate adapter or UI
  integration tests may start the platform or controlled services when needed
  to prove binding at a real boundary. Keep setup/readiness, fixtures, resource
  isolation, observations, and cleanup explicit.
- Require contract checks when fake fidelity affects an acceptance claim or
  drift is evidenced. Consider property or scale tests when input structure
  or size is a demonstrated risk; do not mandate every test level universally.
- Plan controllability before implementation. Hold transient states with
  controlled completion rather than sleeps or racing screenshots.
- Assert observable outcomes, not interactions. Don't expose internals only
  for tests.
- Test pure transitions with plain values (see `state-machines.md`).
- Name tests after the business behavior. Spec acceptance examples map to
  tests by ID where a spec exists.

## Project checks

`.agents/check` is the gate, so it must not pass by doing less.

- A required tool that's missing fails the check, with an install hint. Don't
  make linters "optional when installed": a missing linter then looks
  identical to a clean one.
- If a step genuinely can't run everywhere, print `SKIPPED: <step>` and treat
  it as unverified, not passed: report it and record a `[verify]` follow-up.
  Keep the prefix consistent: `SKIPPED: <step> — <reason>`. Required skips
  prevent completion unless an explicit scope decision removes or reassigns
  the obligation; the command's zero exit status does not override this.
- A check that passed with a step skipped never justifies committing code
  that step would reject.
- Keep output small; every line lands in an agent's context. A passing step
  prints one line, `✓ <step>`. A failing step prints `✗ <step>` and then its
  output. Run every step, but stop each test runner at its first failure
  (`pytest -x`, `jest --bail`, `go test -failfast`):

  ```bash
  step() { # step <name> <command...>
    local name=$1 out; shift
    if out=$("$@" 2>&1); then echo "✓ $name"
    else echo "✗ $name"; echo "$out"; failed=1; fi
  }
  ```
- A git pre-push hook runs `.agents/check`, so unchecked code isn't pushed
  even outside an agent session. Never bypass it with `--no-verify`.

Read [verification.md](verification.md) for required obligations, tree-bound
evidence, observers, and completion dispositions.

## Bug fixes

1. Write a regression test before changing the implementation.
2. Run it against current code and see it fail **for the expected reason**. A
   test that wasn't run, already passes, or fails on setup errors proves
   nothing.
3. Fix, rerun it to green, then run the related existing tests.
4. Keep the regression test. Report the observed failing and passing output.

If a reproducing test can't be written or run, explain why and agree on an
alternative with me before changing code. Never skip this step silently.
