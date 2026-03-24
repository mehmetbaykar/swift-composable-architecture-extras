# LaunchAtLogin

A macOS TCA dependency for managing launch-at-login registration.

## Overview

`LaunchAtLoginClient` provides a testable interface for registering and
unregistering the app as a login item via `SMAppService.mainApp`. Includes
a ready-made SwiftUI `Toggle` view for settings screens.

Based on the [LaunchAtLogin](https://github.com/sindresorhus/LaunchAtLogin)
pattern by Sindre Sorhus.

## Usage

### Access in a Reducer

```swift
@Reducer
struct SettingsFeature {
  @ObservableState
  struct State: Equatable {
    var launchAtLogin: Bool = false
  }

  enum Action: BindableAction {
    case binding(BindingAction<State>)
    case onAppear
    case toggleLaunchAtLogin
  }

  @Dependency(\.launchAtLogin) var launchAtLogin

  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.launchAtLogin = launchAtLogin.isEnabled()
        return .none

      case .toggleLaunchAtLogin:
        state.launchAtLogin.toggle()
        try? launchAtLogin.setEnabled(state.launchAtLogin)
        return .none

      case .binding:
        return .none
      }
    }
  }
}
```

### SwiftUI Toggle

For simple settings screens, use the built-in toggle view that manages
state automatically:

```swift
// With default "Launch at login" label:
LaunchAtLoginClient.Toggle()

// With custom label:
LaunchAtLoginClient.Toggle {
  Text("Open at login")
}
```

The toggle reads the current registration state on appear and calls
`setEnabled` on every change.

### Checking Launch Source

Determine if the current launch was triggered by the login item mechanism
(must be checked in `NSApplicationDelegate.applicationDidFinishLaunching`):

```swift
@Dependency(\.launchAtLogin) var launchAtLogin

func applicationDidFinishLaunching(_ notification: Notification) {
  if launchAtLogin.wasLaunchedAtLogin() {
    // App was opened automatically at login
  }
}
```

### Testing

```swift
let store = TestStore(initialState: SettingsFeature.State()) {
  SettingsFeature()
} withDependencies: {
  $0.launchAtLogin = .noop
}
```

Or with a custom mock:

```swift
$0.launchAtLogin = LaunchAtLoginClient(
  isEnabled: { true },
  setEnabled: { _ in },
  wasLaunchedAtLogin: { false }
)
```

## API

| Property | Type | Description |
|----------|------|-------------|
| `isEnabled` | `@Sendable () -> Bool` | Whether the app is registered to launch at login |
| `setEnabled` | `@Sendable (Bool) throws -> Void` | Enables or disables launch-at-login registration |
| `wasLaunchedAtLogin` | `@Sendable () -> Bool` | Whether the current launch was triggered by the login item |

### SwiftUI Views

| View | Description |
|------|-------------|
| `LaunchAtLoginClient.Toggle` | A toggle that manages launch-at-login state automatically |
| `LaunchAtLoginClient.Toggle(_:)` | Convenience initializer with `LocalizedStringKey` label (defaults to "Launch at login") |

## Platform Support

| Platform | Support |
|----------|---------|
| macOS | Full support via `SMAppService.mainApp` |
| Mac Catalyst | Full support via `SMAppService.mainApp` |
| iOS | Not available (module does not compile) |
| tvOS | Not available (module does not compile) |
| watchOS | Not available (module does not compile) |

## Notes

- **Backend**: Uses `SMAppService.mainApp` (ServiceManagement framework) for registration. The live implementation unregisters before re-registering to avoid stale state.
- **wasLaunchedAtLogin**: Must be checked during `applicationDidFinishLaunching`. Uses `NSAppleEventManager` to inspect the launch Apple Event for `keyAELaunchedAsLogInItem`.
- **Sandboxing**: `SMAppService` works in both sandboxed and non-sandboxed apps. No entitlements required.
