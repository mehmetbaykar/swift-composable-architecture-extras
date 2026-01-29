## Filter

A reducer modifier that conditionally executes the wrapped reducer based on state and action predicates.

## Quick Start

```swift
import ComposableArchitectureExtras

@Reducer
struct CounterReducer {
  @ObservableState
  struct State: Equatable {
    var count = 0
  }

  enum Action {
    case increment
    case decrement
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .increment: state.count += 1
      case .decrement: state.count -= 1
      }
      return .none
    }
    .filter { state, action in
      state.count >= 0 || action == .increment
    }
  }
}
```

## Use Cases

### Feature Flag Toggle

```swift
Reduce { state, action in
  // Premium feature logic
}
.filter { state, _ in
  state.isFeatureEnabled
}
```

### Boundary Enforcement

```swift
Reduce { state, action in
  switch action {
  case .increment: state.count += 1
  case .decrement: state.count -= 1
  }
  return .none
}
.filter { state, action in
  switch action {
  case .increment: state.count < 10
  case .decrement: state.count > 0
  }
}
```

### Action Whitelisting

```swift
Reduce { state, action in
  // Handle all actions
}
.filter { state, action in
  switch action {
  case .dangerousAction:
    state.isAdmin
  default:
    true
  }
}
```

## Composition

Combine `.filter` with other reducer modifiers:

```swift
var body: some ReducerOf<Self> {
  BindingReducer()

  Reduce { state, action in
    // Business logic
  }
  .filter { state, action in
    state.isEnabled
  }

  AnalyticsReducerOf<Self, AppEvent> { state, action in
    // Track events
  }
}
```

## Full Example

```swift
import ComposableArchitectureExtras

@Reducer
struct SettingsReducer {
  @ObservableState
  struct State: Equatable {
    var volume: Int = 50
    var brightness: Int = 50
    var isPremiumUser = false
    var isEditingEnabled = true
  }

  enum Action: BindableAction {
    case binding(BindingAction<State>)
    case increaseVolume
    case decreaseVolume
    case increaseBrightness
    case decreaseBrightness
    case resetToDefaults
  }

  var body: some ReducerOf<Self> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .binding:
        return .none
      case .increaseVolume:
        state.volume = min(100, state.volume + 10)
        return .none
      case .decreaseVolume:
        state.volume = max(0, state.volume - 10)
        return .none
      case .increaseBrightness:
        state.brightness = min(100, state.brightness + 10)
        return .none
      case .decreaseBrightness:
        state.brightness = max(0, state.brightness - 10)
        return .none
      case .resetToDefaults:
        state.volume = 50
        state.brightness = 50
        return .none
      }
    }
    .filter { state, action in
      // Block all modifications when editing is disabled
      guard state.isEditingEnabled else {
        return false
      }

      // Premium-only actions
      switch action {
      case .resetToDefaults:
        return state.isPremiumUser
      default:
        return true
      }
    }
  }
}
```
