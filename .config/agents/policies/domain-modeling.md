# Domain modeling

Make illegal states unrepresentable. Encode invariants in types so callers
can't forget them, and parse untrusted data once, at the boundary.

Reference: Scott Wlaschin, *Domain Modeling Made Functional*.

## Example: states as a sum type

Before: flags and nullable fields allow contradictions (shipped but unpaid?
shipped with no tracking number?).

```kotlin
data class Order(
    val id: String,
    val isPaid: Boolean,
    val isShipped: Boolean,
    val trackingNumber: String?,
    val paidAt: Instant?,
)
```

After: each state carries exactly the data it needs.

```kotlin
sealed interface Order {
    val id: OrderId
    data class Unpaid(override val id: OrderId, val lines: NonEmptyList<OrderLine>) : Order
    data class Paid(override val id: OrderId, val lines: NonEmptyList<OrderLine>, val paidAt: Instant) : Order
    data class Shipped(override val id: OrderId, val paidAt: Instant, val tracking: TrackingNumber) : Order
}

fun ship(order: Order.Paid, tracking: TrackingNumber): Order.Shipped = ...
```

`ship` can't be called on an unpaid order; the compiler enforces the rule.

## Example: constrained values with a smart constructor

```kotlin
@JvmInline
value class EmailAddress private constructor(val value: String) {
    companion object {
        fun parse(raw: String): EmailAddress? =
            raw.trim().takeIf { EMAIL_REGEX.matches(it) }?.let(::EmailAddress)
    }
}
```

After parsing at the boundary, the rest of the code takes `EmailAddress`, never
`String`, and never re-validates.

## Rules

- Distinct types for distinct meanings even when the representation is the
  same (`OrderId` vs `CustomerId`, not two `String`s).
- Mutually exclusive states are sum types; handle them exhaustively (`when`
  without `else`).
- Make transitions explicit in signatures: `Paid -> Shipped`, not
  `Order -> Order`.
- Parse, don't validate: boundaries turn DTOs and raw input into domain values
  or a typed error. Static types don't replace runtime validation of input.
- When the language can't express an invariant statically, guard it behind a
  narrow construction API. Don't pretend a cast or annotation guarantees it.

## Language and contexts

- Use the project's ubiquitous language (`docs/CONTEXT.md`) in type and function
  names. When a new term appears or a term is ambiguous, raise it and update
  the glossary.
- Clarify uncertain business rules before encoding them; a wrong type is
  costlier than a question.
- Each bounded context owns its model. The same word in two contexts can be two
  types, translated at the boundary.
