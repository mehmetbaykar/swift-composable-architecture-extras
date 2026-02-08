# Swift Composable Architecture Extras

![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-blue.svg)
![CI](https://github.com/mehmetbaykar/swift-composable-architecture-extras/actions/workflows/ci.yml/badge.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

Production-ready reducer patterns and utilities for The Composable Architecture.

## Table of Contents

- [Philosophy](#philosophy)
- [Installation](#installation)
- [Requirements](#requirements)
- [Reducer Modules](#reducer-modules)
  - [Analytics](#analytics)
  - [Filter](#filter)
  - [FormValidation](#formvalidation)
  - [Haptics](#haptics)
  - [Printers](#printers)
  - [ScreenAwake](#screenawake)
  - [ScreenBrightness](#screenbrightness)
- [Dependency Modules](#dependency-modules)
  - [AppInfo](#appinfo)
  - [DeviceInfo](#deviceinfo)
  - [OpenSettings](#opensettings)
  - [OpenURL](#openurl)
- [Contributing](#contributing)
- [Acknowledgments](#acknowledgments)
- [License](#license)

## Philosophy

These are production-ready patterns extracted from real TCA applications. Each module solves a common problem with minimal API surface and maximum composability.

## Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/mehmetbaykar/swift-composable-architecture-extras.git", from: "1.0.0")
]
```

Then add the product to your target:

```swift
.target(
  name: "YourTarget",
  dependencies: [
    .product(name: "ComposableArchitectureExtras", package: "swift-composable-architecture-extras")
  ]
)
```

## Requirements

| Platform | Minimum Version |
|----------|-----------------|
| iOS | 13.0+ |
| macOS | 10.15+ |
| tvOS | 13.0+ |
| watchOS | 6.0+ |
| Swift | 6.0+ |
| TCA | 1.23.1+ |

## Reducer Modules

### Analytics

A generic analytics reducer that handles provider integration using a declarative result builder syntax. Define events once, track everywhere.

```swift
AnalyticsReducerOf<Self, AppEvent> { state, action in
  switch action {
  case .viewAppeared: .screenViewed(name: "Home")
  case .dismissed: []
  }
}
```

[Full documentation](Sources/Reducers/Analytics/README.md)

### Filter

A reducer modifier that conditionally executes the wrapped reducer based on state and action predicates. Perfect for feature flags, boundary enforcement, and action gating.

```swift
Reduce { state, action in
  // Business logic
}
.filter { state, action in
  state.isFeatureEnabled
}
```

[Full documentation](Sources/Reducers/Filter/README.md)

### FormValidation

A declarative form validation system with automatic error state management. Define validation rules once, get real-time feedback on every field change.

```swift
FormValidationReducer(
  submitAction: \.submitTapped,
  onFormValidatedAction: .loginSucceeded,
  validations: [
    FieldValidation(field: \.email, errorState: \.emailError, rules: [.nonEmpty(fieldName: "Email")])
  ]
)
```

[Full documentation](Sources/Reducers/FormValidation/README.md)

### Haptics

A universal haptics module that provides state-triggered haptic feedback across iOS, macOS, and watchOS. Trigger haptics declaratively when state changes.

```swift
Reduce { state, action in
  // Business logic
}
.haptics(.selection, triggerOnChangeOf: \.selectedIndex)
.haptics(.impactMedium(), triggerOnChangeOf: \.count, isEnabled: \.hapticsEnabled)
```

[Full documentation](Sources/Reducers/Haptics/README.md)

### Printers

Debug printing utilities with customizable action filtering and formatted output.

```swift
Reduce { state, action in
  // Business logic
}
._printChanges(.prettyConsole(
  allowedActions: .not(.init { if case .binding = $0 { true } else { false } }),
  showTimestamp: true
))
```

[Full documentation](Sources/Reducers/Printers/README.md)

### ScreenAwake

Prevents device screen from auto-locking during specific app states. Works across iOS, tvOS, macOS, and watchOS with platform-appropriate implementations.

```swift
Reduce { state, action in
  // Business logic
}
.screenAwake(when: \.isPlaying)
```

[Full documentation](Sources/Reducers/ScreenAwake/README.md)

### ScreenBrightness

State-triggered screen brightness control for TCA applications. Automatically adjusts screen brightness based on state changes with smart restoration to original brightness.

```swift
Reduce { state, action in
  // Business logic
}
.screenBrightness(level: \.brightnessLevel)
```

> **Platform Support**: iOS only. macOS, watchOS, and tvOS compile but are no-ops (no public brightness APIs exist).

[Full documentation](Sources/Reducers/ScreenBrightness/README.md)

## Dependency Modules

### AppInfo

A lightweight TCA dependency for accessing app bundle metadata including version strings, build numbers, and bundle identifiers.

```swift
@Dependency(\.appInfo) var appInfo

let version = appInfo.appVersion()
let build = appInfo.buildNumber()
let bundleId = appInfo.bundleIdentifier()
```

[Full documentation](Sources/Dependencies/AppInfo/README.md)

### DeviceInfo

A cross-platform TCA dependency for accessing device system information: CPU usage, memory, disk storage, battery, network connectivity, thermal state, and device identity.

```swift
@Dependency(\.deviceInfo) var deviceInfo

let identity = await deviceInfo.identity()
let cpu = await deviceInfo.cpu()
let memory = deviceInfo.memory()
let disk = deviceInfo.disk()
let thermal = deviceInfo.thermalState()

#if !os(tvOS)
let battery = await deviceInfo.battery()
#endif

#if !os(watchOS)
let network = deviceInfo.network()
#endif
```

> **Platform Support**: iOS, macOS, tvOS, watchOS. Battery excluded on tvOS, network excluded on watchOS.

[Full documentation](Sources/Dependencies/DeviceInfo/README.md)

### OpenSettings

A cross-platform TCA dependency for opening system settings. Platform-specific enum cases ensure consumers only see options their platform supports.

```swift
@Dependency(\.openSettings) var openSettings

await openSettings.open(.general)
```

[Full documentation](Sources/Dependencies/OpenSettings/README.md)

### OpenURL

A cross-platform TCA dependency for opening URLs externally or in-app via SFSafariViewController (iOS).

```swift
@Dependency(\.customOpenURL) var openURL

// Open externally (all platforms)
await openURL(URL(string: "https://example.com")!)

// Open in-app (iOS only)
#if os(iOS)
await openURL(URL(string: "https://example.com")!, prefersInApp: true)
#endif
```

> **Platform Support**: iOS (external + in-app), macOS, tvOS, visionOS (external only). watchOS excluded.

[Full documentation](Sources/Dependencies/OpenURL/README.md)

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=mehmetbaykar/swift-composable-architecture-extras&type=date&legend=top-left)](https://www.star-history.com/#mehmetbaykar/swift-composable-architecture-extras&type=date&legend=top-left)

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Acknowledgments

Built on top of [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) by [Point-Free](https://www.pointfree.co).

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
