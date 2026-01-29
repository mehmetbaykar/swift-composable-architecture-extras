## Haptics

A universal haptics module for TCA that provides state-trigger based haptic feedback across iOS, macOS, and watchOS.

## Quick Start

```swift
@Reducer
struct Feature {
  @ObservableState
  struct State { var selectedIndex = 0 }
  enum Action { case selectIndex(Int) }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .selectIndex(let index):
        state.selectedIndex = index
        return .none
      }
    }
    .haptics(.selection, triggerOnChangeOf: \.selectedIndex)
  }
}
```

## HapticFeedback Types

### iOS

| Type | Description |
|------|-------------|
| `.success` | Task completed successfully |
| `.warning` | Task produced a warning |
| `.error` | Task failed |
| `.impactLight(intensity:)` | Light impact (default intensity: 1.0) |
| `.impactMedium(intensity:)` | Medium impact (default intensity: 1.0) |
| `.impactHeavy(intensity:)` | Heavy impact (default intensity: 1.0) |
| `.impactRigid(intensity:)` | Rigid impact (default intensity: 1.0) |
| `.impactSoft(intensity:)` | Soft impact (default intensity: 1.0) |
| `.selection` | Selection changed |

### macOS

| Type | Description |
|------|-------------|
| `.alignment` | Snapping to guides, alignment indicators |
| `.levelChange` | Discrete level changes (volume steps, scrubber) |
| `.generic` | General-purpose feedback |

**Note:** macOS haptics require a Force Touch trackpad (built-in or Magic Trackpad). On devices without haptic support, feedback calls are silently ignored.

### watchOS

| Type | Description |
|------|-------------|
| `.watchNotification` | Notification haptic |
| `.watchDirectionUp` | Upward movement |
| `.watchDirectionDown` | Downward movement |
| `.watchSuccess` | Success haptic |
| `.watchFailure` | Failure haptic |
| `.watchRetry` | Retry haptic |
| `.watchStart` | Start action (e.g., workout) |
| `.watchStop` | Stop action (e.g., workout) |
| `.watchClick` | Click haptic (Digital Crown detents) |

**Note:** watchOS haptics may include audio feedback by default.

## Usage Patterns

### Basic Trigger

```swift
.haptics(.selection, triggerOnChangeOf: \.selectedIndex)
```

### With Intensity

```swift
.haptics(.impactMedium(intensity: 0.8), triggerOnChangeOf: \.count)
```

### Conditional Enable

Using a closure:

```swift
.haptics(
  .selection,
  triggerOnChangeOf: \.selectedIndex,
  isEnabled: { state in state.settings.hapticsEnabled }
)
```

Using a KeyPath:

```swift
.haptics(
  .selection,
  triggerOnChangeOf: \.selectedIndex,
  isEnabled: \.settings.hapticsEnabled
)
```

### Multiple Haptics

Chain multiple `.haptics()` calls for different triggers:

```swift
Reduce { state, action in
  // ...
}
.haptics(.selection, triggerOnChangeOf: \.selectedTab)
.haptics(.impactLight(), triggerOnChangeOf: \.scrollPosition)
.haptics(.success, triggerOnChangeOf: \.isCompleted)
```

## Full Example

```swift
@Reducer
struct TabBarReducer {
  @ObservableState
  struct State: Equatable {
    var selectedTab: Tab = .home
    var notificationCount: Int = 0
    var isHapticsEnabled: Bool = true

    enum Tab { case home, search, profile }
  }

  enum Action {
    case selectTab(State.Tab)
    case receiveNotification
    case toggleHaptics
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .selectTab(let tab):
        state.selectedTab = tab
        return .none
      case .receiveNotification:
        state.notificationCount += 1
        return .none
      case .toggleHaptics:
        state.isHapticsEnabled.toggle()
        return .none
      }
    }
    // Selection feedback for tab changes
    .haptics(.selection, triggerOnChangeOf: \.selectedTab, isEnabled: \.isHapticsEnabled)
    // Impact feedback for notifications
    .haptics(.impactMedium(), triggerOnChangeOf: \.notificationCount, isEnabled: \.isHapticsEnabled)
  }
}
```

## Platform-Specific Examples

### iOS

```swift
.haptics(.success, triggerOnChangeOf: \.isTaskCompleted)
.haptics(.impactHeavy(intensity: 0.7), triggerOnChangeOf: \.dragPosition)
```

### macOS

```swift
.haptics(.alignment, triggerOnChangeOf: \.snappedToGrid)
.haptics(.levelChange, triggerOnChangeOf: \.volumeLevel)
```

### watchOS

```swift
.haptics(.watchSuccess, triggerOnChangeOf: \.workoutCompleted)
.haptics(.watchClick, triggerOnChangeOf: \.crownPosition)
```

## Latency Optimization

For time-sensitive haptics, prepare the feedback generator in advance:

```swift
@Dependency(\.feedbackGenerator) var feedbackGenerator

// In your reducer:
return .run { [feedbackGenerator] _ in
  await feedbackGenerator.prepare(.impactMedium())
  // ... perform animation ...
  await feedbackGenerator.generate(.impactMedium())
}
```

## Testing

Use `FeedbackCollector` to capture haptic events in tests:

```swift
@Test("selection haptic triggers on tab change")
@MainActor
func selectionHapticTriggersOnTabChange() async {
  let collector = FeedbackCollector()

  let store = TestStore(initialState: TabBarReducer.State()) {
    TabBarReducer()
  } withDependencies: {
    $0.feedbackGenerator = AnyFeedbackGeneratorClient(collector.client)
  }

  await store.send(.selectTab(.search)) {
    $0.selectedTab = .search
  }

  #expect(collector.feedbacks == [.selection])
}
```

## Register with TCA

```swift
@main
struct MyApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView(
        store: Store(initialState: AppReducer.State()) {
          AppReducer()
        } withDependencies: {
          $0.feedbackGenerator = AnyFeedbackGeneratorClient(.live)
        }
      )
    }
  }
}
```

## Built-in Providers

- `.live` – Platform-specific haptic implementation
- `.consoleLogger()` – Prints events in DEBUG builds
- `.noop()` – Discards all events
- `.merge(...)` – Combines multiple clients

## Platform Support

| Platform | Minimum Version | API |
|----------|-----------------|-----|
| iOS | 13.0 | UIFeedbackGenerator |
| macOS | 10.15 | NSHapticFeedbackManager |
| watchOS | 6.0 | WKInterfaceDevice |
| tvOS | 13.0 | No haptic support (no-op) |

## Notes

- **Simulator:** Haptics won't be felt in the Simulator – test on physical devices
- **System Settings:** Haptics automatically respect the user's system preferences
- **Force Touch:** macOS haptics require a Force Touch trackpad
- **Thread Safety:** All haptic generation is dispatched to the main actor
