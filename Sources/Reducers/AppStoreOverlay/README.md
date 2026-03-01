# AppStoreOverlay

State-driven App Store overlay presentation for TCA applications.

> **Platform Support**: iOS only. Uses `SKOverlay.AppConfiguration` via SwiftUI's `.appStoreOverlay(isPresented:configuration:)`.

## Overview

AppStoreOverlay bridges SwiftUI's `.appStoreOverlay` modifier with TCA's state management. Set `state.overlay` to present, nil it to dismiss. Follows the same `@Presents`/`ifLet` pattern as TCA's built-in alert and confirmationDialog.

## Usage

### Reducer

```swift
import ComposableArchitecture

@Reducer
struct MyFeature {
  @ObservableState
  struct State: Equatable {
    @Presents var overlay: AppStoreOverlayReducer.State?
  }

  enum Action {
    case showOverlayTapped
    case overlay(PresentationAction<AppStoreOverlayReducer.Action>)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .showOverlayTapped:
        state.overlay = .init(appIdentifier: "1511409657")
        return .none
      case .overlay:
        return .none
      }
    }
    .ifLet(\.$overlay, action: \.overlay) {
      AppStoreOverlayReducer()
    }
  }
}
```

### View

```swift
struct MyView: View {
  @Perception.Bindable var store: StoreOf<MyFeature>

  var body: some View {
    WithPerceptionTracking {
      VStack {
        Button("Show Overlay") {
          store.send(.showOverlayTapped)
        }
      }
      .appStoreOverlay(
        $store.scope(state: \.overlay, action: \.overlay)
      )
    }
  }
}
```

## API Reference

### AppStoreOverlayReducer.State

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `appIdentifier` | `String` | (required) | App Store app ID |
| `position` | `SKOverlay.Position` | `.bottom` | Overlay position |

### Presentation

- **Show**: `state.overlay = .init(appIdentifier: "1511409657")`
- **Show with position**: `state.overlay = .init(appIdentifier: "1511409657", position: .bottomRaised)`
- **Dismiss programmatically**: `state.overlay = nil`
- **Dismiss by user swipe**: Handled automatically via `PresentationAction.dismiss`

## Testing

```swift
@Test @MainActor
func showOverlayPresentsState() async {
  let store = TestStore(
    initialState: MyFeature.State(),
    reducer: MyFeature.init
  )

  await store.send(.showOverlayTapped) {
    $0.overlay = AppStoreOverlayReducer.State(appIdentifier: "1511409657")
  }
}
```

## Notes

- The overlay is dismissed when the user swipes it away or when `state.overlay` is set to `nil`
- The `appIdentifier` is the numeric App Store ID (found in the app's App Store URL)
- `SKOverlay` requires iOS 14+; on earlier versions the modifier is a no-op
