# Printers

Debug printing utilities with customizable action filtering and formatted output for The Composable Architecture.

## Quick Start

Add pretty-printed debug output to any reducer:

```swift
Reduce { state, action in
  // Business logic
}
._printChanges(.prettyConsole())
```

Output:
```
┌──────────────────────────────────────┐
│[DEBUG OUTPUT]                        │
├──────────────────────────────────────┤
│ [>] ACTION:                          │
│  Feature.Action.buttonTapped         │
├──────────────────────────────────────┤
│ [S] STATE:                           │
│  Feature.State(                      │
│-   count: 0                          │
│+   count: 1                          │
│  )                                   │
└──────────────────────────────────────┘
```

## Action Filtering

Control which actions trigger debug output using `ActionFilter`:

### Print Only Specific Actions

```swift
._printChanges(.prettyConsole(
  allowedActions: .anyOf(
    .init { if case .loginTapped = $0 { true } else { false } },
    .init { if case .logoutTapped = $0 { true } else { false } }
  )
))
```

### Exclude Binding Actions

```swift
._printChanges(.prettyConsole(
  allowedActions: .not(
    .init { if case .binding = $0 { true } else { false } }
  )
))
```

### Exclude Multiple Action Types

```swift
._printChanges(.prettyConsole(
  allowedActions: .allExcept(
    .init { if case .binding = $0 { true } else { false } },
    .init { if case .delegate = $0 { true } else { false } }
  )
))
```

### Filter Combinators

| Method | Description |
|--------|-------------|
| `.all` | Include all actions (default) |
| `.not(filter)` | Invert a filter |
| `.anyOf(filters...)` | Include if any filter matches |
| `.allExcept(filters...)` | Exclude matching actions |

## Configuration Options

### maxDepth

Control how deep nested structures are printed:

```swift
._printChanges(.prettyConsole(maxDepth: 5))  // Limit depth to 5 levels
```

### showTimestamp

Add ISO 8601 timestamps to output headers:

```swift
._printChanges(.prettyConsole(showTimestamp: true))
```

Output:
```
┌────────────────────────────────────────────────────┐
│[DEBUG OUTPUT] 2024-01-29T15:30:45.123Z             │
├────────────────────────────────────────────────────┤
```

### debounceInterval

Limit output frequency by setting a minimum interval between prints:

```swift
._printChanges(.prettyConsole(debounceInterval: 0.5))  // Max 2 prints per second
```

Actions within the debounce interval are silently skipped.

## JSON Printer

For log aggregation systems, use the JSON printer:

```swift
._printChanges(.json())
```

Output (single-line, formatted here for readability):
```json
{
  "timestamp": "2024-01-29T15:30:45.123Z",
  "action": "Feature.Action.buttonTapped",
  "diff": "count: 0 → 1"
}
```

### JSON Printer Options

```swift
._printChanges(.json(
  allowedActions: .all,      // Same filtering as prettyConsole
  maxDepth: 10,              // Depth for action output
  debounceInterval: nil      // Optional debouncing
))
```

## Full Example

```swift
@Reducer
struct Feature {
  @ObservableState
  struct State: Equatable {
    var count = 0
    var isLoading = false
  }

  enum Action: Equatable {
    case incrementTapped
    case decrementTapped
    case binding(BindingAction<State>)
    case delegate(Delegate)

    enum Delegate: Equatable {
      case countChanged(Int)
    }
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .incrementTapped:
        state.count += 1
        return .none
      case .decrementTapped:
        state.count -= 1
        return .none
      case .binding, .delegate:
        return .none
      }
    }
    #if DEBUG
    ._printChanges(.prettyConsole(
      allowedActions: .allExcept(
        .init { if case .binding = $0 { true } else { false } },
        .init { if case .delegate = $0 { true } else { false } }
      ),
      showTimestamp: true
    ))
    #endif
  }
}
```

## API Reference

### PrettyPrinter

```swift
extension _ReducerPrinter {
  static func prettyConsole(
    allowedActions: ActionFilter<Action> = .all,
    maxDepth: Int = 10,
    showTimestamp: Bool = false,
    debounceInterval: TimeInterval? = nil
  ) -> Self
}
```

### JSONPrinter

```swift
extension _ReducerPrinter {
  static func json(
    allowedActions: ActionFilter<Action> = .all,
    maxDepth: Int = 10,
    debounceInterval: TimeInterval? = nil
  ) -> Self
}
```

### ActionFilter

```swift
struct ActionFilter<Action>: Sendable {
  init(isIncluded: @Sendable @escaping (Action) -> Bool)

  static var all: Self
  static func not(_ filter: Self) -> Self
  static func anyOf(_ actions: Self...) -> Self
  static func allExcept(_ actions: Self...) -> Self
}
```
