# Functional core, imperative shell

Decisions are pure functions over explicit inputs. Effects run in a thin shell
that gathers inputs, calls the core, and executes the result. Dependencies
point toward the domain.

Reference: Scott Wlaschin,
[A primer on functional architecture](https://increment.com/software-architecture/primer-on-functional-architecture/).

## Example

Before: the decision is tangled with the clock, the database, and the network.

```kotlin
class RenewSubscription(private val db: Database, private val billing: BillingApi) {
    suspend fun renew(id: String) {
        val sub = db.findSubscription(id)
        if (sub.expiresAt.isBefore(Instant.now()) && !sub.cancelled) {
            billing.charge(sub.customerId, sub.price)
            db.save(sub.copy(expiresAt = Instant.now().plus(30, DAYS)))
        }
    }
}
```

After: the core decides; the shell gathers inputs and performs effects.

```kotlin
// Core: pure, no I/O, the clock is an argument.
fun decideRenewal(sub: Subscription, now: Instant): RenewalDecision = when (sub) {
    is Subscription.Cancelled -> RenewalDecision.Skip
    is Subscription.Active ->
        if (sub.expiresAt > now) RenewalDecision.Skip
        else RenewalDecision.Renew(charge = sub.price, newExpiry = now + sub.period)
}

// Shell: thin, effectful, no business rules.
class RenewSubscription(
    private val subscriptions: SubscriptionRepository,
    private val billing: Billing,
    private val clock: Clock,
) {
    suspend fun renew(id: SubscriptionId) {
        val sub = subscriptions.get(id)
        when (val decision = decideRenewal(sub, clock.now())) {
            RenewalDecision.Skip -> Unit
            is RenewalDecision.Renew -> {
                billing.charge(sub.customerId, decision.charge)
                subscriptions.save(sub.renewedUntil(decision.newExpiry))
            }
        }
    }
}
```

The core is tested with plain values. The shell is tested once with fakes.

## Rules

- Pass the values a decision needs as arguments, including time and IDs.
  Harmless local mutation inside a function is fine.
- Domain code must not import persistence, transport, framework, or platform
  packages. Translate external representations in adapters at the edge.
- Organize by business capability and workflow, not by technical layer.
  Code that changes together lives together.
- Don't reach into another bounded context's internals or share models because
  they look alike. Integrate through explicit contracts.
- Logical boundaries are not deployment boundaries. Contexts don't imply
  separate services, databases, or build modules.

## Dependency injection

- Start from the interface the caller needs, named in domain terms, before any
  implementation.
- Classes receive dependencies through the constructor. No service locators,
  globals, or constructing dependencies internally. Wire concrete
  implementations at the composition root.
- Public interfaces expose domain operations and outcomes. Internal state
  machines, event dispatch, and effect execution stay private.

## Platform independence

Business logic must run on any platform, and the test runner counts as one.

- Wrap platform APIs behind internal interfaces in domain terms, e.g.
  `android.util.Log` behind a `Logger` with Android and test implementations.
- No platform types, `Context`, or lifecycle objects in business interfaces.
- Business tests run as plain JVM tests: no emulator, device, or Robolectric.
  Platform integration tests cover only the adapters.
- This keeps new platforms (e.g. KMP for iOS) possible. It is not a reason to
  add speculative adapters now.

## Errors

- Expected failures are typed results (sealed types) inside the implementation.
- At a public library or SDK boundary, translate them to the ecosystem's
  idiomatic mechanism (exceptions on the JVM). Callers never need internal
  result types.
- Public error types are part of the API contract: map deliberately, keep
  causes, hide internals.

## Enforcement

In a project, prefer a dependency lint (Konsist, ArchUnit, dependency-cruiser,
import-linter) over relying on this document. Write its failure messages as
fix instructions, e.g. *"domain/ must not import db/. Pass the value in as an
argument; see policies/functional-core.md."*
