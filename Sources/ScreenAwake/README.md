# ScreenAwake

Prevents device screen from auto-locking during specific app states.

## Usage

```swift
@Reducer
struct MyFeature {
  @ObservableState
  struct State: Equatable {
    var isPlaying = false
  }

  enum Action {
    case play
    case pause
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .play:
        state.isPlaying = true
        return .none
      case .pause:
        state.isPlaying = false
        return .none
      }
    }
    .screenAwake(when: \.isPlaying)
  }
}
```

## Platform Support

| Platform | Behavior |
|----------|----------|
| iOS | Disables idle timer |
| tvOS | Disables screensaver |
| macOS | Prevents display sleep via IOKit power assertions |
| watchOS | No-op (not supported) |

## Notes

- Apply `.screenAwake(when:)` at the appropriate reducer level for your use case
- Screen stays awake when the trigger closure returns `true`
- Screen auto-lock is re-enabled when the trigger closure returns `false`
