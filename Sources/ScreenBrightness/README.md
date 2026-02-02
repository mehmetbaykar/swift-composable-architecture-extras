# ScreenBrightness

State-triggered screen brightness control for TCA applications.

> **Platform Support**: iOS only. macOS, watchOS, and tvOS compile but are no-ops (no public brightness APIs exist).

## Overview

ScreenBrightness provides a declarative way to control device screen brightness based on your app's state. When the observed state changes, the screen brightness automatically adjusts.

## Usage

### Basic Usage

```swift
import ComposableArchitecture
import ScreenBrightness

@Reducer
struct VideoPlayer {
  @ObservableState
  struct State: Equatable {
    var isPlaying = false
    var brightnessLevel: BrightnessLevel = .automatic
  }

  enum Action {
    case playTapped
    case stopTapped
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .playTapped:
        state.isPlaying = true
        state.brightnessLevel = .max  // Maximize for video
        return .none
      case .stopTapped:
        state.isPlaying = false
        state.brightnessLevel = .automatic  // Restore original
        return .none
      }
    }
    .screenBrightness(level: \.brightnessLevel)
  }
}
```

### Navigation Example (Parent-Child Restoration)

```swift
@Reducer
struct ParentFeature {
  @ObservableState
  struct State: Equatable {
    var brightness: BrightnessLevel = .automatic
    @Presents var scanner: ScannerFeature.State?
  }

  enum Action {
    case openScanner
    case scanner(PresentationAction<ScannerFeature.Action>)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .openScanner:
        state.brightness = .max  // Maximize for scanning
        state.scanner = ScannerFeature.State()
        return .none
      case .scanner(.dismiss):
        state.brightness = .automatic  // Restore when dismissed
        return .none
      default:
        return .none
      }
    }
    .ifLet(\.$scanner, action: \.scanner) {
      ScannerFeature()
    }
    .screenBrightness(level: \.brightness)
  }
}
```

### Progress-Based Brightness

```swift
@Reducer
struct ProgressFeature {
  @ObservableState
  struct State: Equatable {
    var progress: Double = 0
    var brightnessLevel: BrightnessLevel = .low
  }

  enum Action {
    case updateProgress(Double)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .updateProgress(let value):
        state.progress = value
        if value >= 1.0 {
          state.brightnessLevel = .automatic
        } else {
          state.brightnessLevel = .custom(value)
        }
        return .none
      }
    }
    .screenBrightness(level: \.brightnessLevel)
  }
}
```

## API Reference

### BrightnessLevel

An enum representing the target screen brightness:

| Case | Value | Description |
|------|-------|-------------|
| `.automatic` | `nil` | Restores the original brightness captured before first change |
| `.low` | `0.1` | 10% brightness |
| `.medium` | `0.5` | 50% brightness |
| `.high` | `0.9` | 90% brightness |
| `.max` | `1.0` | 100% brightness |
| `.custom(Double)` | `0.0-1.0` | Custom brightness value |

### Reducer Modifier

```swift
.screenBrightness(level: KeyPath<State, BrightnessLevel>)
```

Observes the specified state keypath and triggers brightness changes when the value changes.

## Restoration Behavior

The module implements smart brightness restoration:

1. **First change**: Captures the current screen brightness as the "original" value
2. **Subsequent changes**: Applies new brightness levels directly
3. **Automatic mode**: Restores the captured original brightness
4. **After restoration**: Clears the saved value (one-time restoration)

> **Note**: This is a single-shot restoration pattern. For complex nested scenarios, manage brightness state explicitly in your reducer.

## Platform Limitations

| Platform | Status | Notes |
|----------|--------|-------|
| iOS | Full Support | Uses `UIScreen.main.brightness` |
| macOS | No-op | No public API (DisplayServices is private) |
| watchOS | No-op | No API exists |
| tvOS | No-op | No API exists |

### Important Notes

- **iOS brightness persists**: Changes to `UIScreen.main.brightness` persist system-wide, even after your app closes
- **User responsibility**: If your app crashes before calling `.automatic`, brightness remains at the last set value
- **Testing**: In tests and previews, a no-op client is used by default

## Testing

Use dependency injection to verify brightness behavior:

```swift
@MainActor
func testBrightnessChange() async {
  var capturedLevels: [BrightnessLevel] = []

  let store = TestStore(initialState: Feature.State()) {
    Feature()
  } withDependencies: {
    $0.screenBrightness = ScreenBrightnessClient(
      set: { level in capturedLevels.append(level) }
    )
  }

  await store.send(.maximize) {
    $0.brightness = .max
  }

  #expect(capturedLevels == [.max])
}
```
