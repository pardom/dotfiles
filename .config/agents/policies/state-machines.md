# State machines

Beyond one or two simple state properties, model behavior as an explicit state
machine with a pure transition function. This applies to domain workflows,
protocols, SDK lifecycles, and UI.

Reference: Andy Matuschak,
[A composable pattern for pure state machines with effects](https://gist.github.com/andymatuschak/d5f0a8730ad601bcccae97e8398e25b2).

## Example

```kotlin
sealed interface State {
    data object Idle : State
    data class Loading(val query: Query) : State
    data class Loaded(val query: Query, val results: List<Result>) : State
    data class Failed(val query: Query, val error: SearchError) : State
}

sealed interface Event {
    data class Submitted(val query: Query) : Event
    data class ResultsArrived(val query: Query, val results: List<Result>) : Event
    data class SearchFailed(val query: Query, val error: SearchError) : Event
}

sealed interface Command {
    data class Search(val query: Query) : Command
}

fun transition(state: State, event: Event): Pair<State, List<Command>> = when (event) {
    is Event.Submitted -> State.Loading(event.query) to listOf(Command.Search(event.query))
    is Event.ResultsArrived ->
        if (state is State.Loading && state.query == event.query) State.Loaded(event.query, event.results) to emptyList()
        else state to emptyList() // stale response: deliberate no-op
    is Event.SearchFailed ->
        if (state is State.Loading && state.query == event.query) State.Failed(event.query, event.error) to emptyList()
        else state to emptyList()
}
```

An interpreter in the shell executes `Command.Search` and feeds the outcome
back as `ResultsArrived` or `SearchFailed`.

Test: `transition(Loading(q), ResultsArrived(q, rs)) == Loaded(q, rs) to emptyList()`.
No coroutines, fakes, or timing needed.

## Rules

- States, events, and commands are typed data. Transitions are
  `(state, event) -> (state, commands)` and pure.
- Effects are commands executed by a separate interpreter. Async outcomes come
  back as events. Decisions stay in the machine.
- Define the initial state. Handle every event in every state, and mark
  intentional no-ops explicitly.
- UI: the transition also produces render descriptions. The shell applies them
  through the UI framework; framework objects stay in adapters.
- Compose nested machines for hierarchy and independent machines for
  orthogonal concerns. Route events and propagate commands explicitly.
- The machine is usually an implementation detail behind an interface. Expose
  states or events only when they're part of the domain contract.
- Test transitions by asserting next state and commands. Test the interpreter
  separately. No state-machine library required.
