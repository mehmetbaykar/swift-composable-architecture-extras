# Swift Composable Architecture Extras

![Swift](https://img.shields.io/badge/Swift-6.3-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-blue.svg)
![CI](https://github.com/mehmetbaykar/swift-composable-architecture-extras/actions/workflows/ci.yml/badge.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

<p align="center">
If you found this helpful, you can support more open source work!
<br><br>
<a href="https://buymeacoffee.com/mehmetbaykar" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="60"></a>
</p>

---

Production-ready reducer patterns and dependencies for The Composable Architecture.

## Table of Contents

- [Philosophy](#philosophy)
- [Installation](#installation)
- [Requirements](#requirements)
- [Reducer Modules](#reducer-modules)
  - [Analytics](#analytics)
  - [AppStoreOverlay](#appstoreoverlay)
  - [Filter](#filter)
  - [FormValidation](#formvalidation)
  - [Haptics](#haptics)
  - [Printers](#printers)
  - [ScreenAwake](#screenawake)
  - [ScreenBrightness](#screenbrightness)
- [Dependency Modules](#dependency-modules)
  - [AppInfo](#appinfo)
  - [AudioPlayer](#audioplayer)
  - [DeviceInfo](#deviceinfo)
  - [LaunchAtLogin](#launchatlogin)
  - [LoggerClient](#loggerclient)
  - [OpenSettings](#opensettings)
  - [OpenURL](#openurl)
  - [ShellClient](#shellclient)
- [Privacy Manifest](#privacy-manifest)
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

### Package Traits

The `ComposableArchitectureExtras` product supports SwiftPM package traits so you can include only the modules you need:

| Configuration | Dependency declaration |
| ------------- | ---------------------- |
| Both (default) | `.package(url: "...", from: "1.0.0")` |
| Dependencies only | `.package(url: "...", from: "1.0.0", traits: ["Dependencies"])` |
| Reducers only | `.package(url: "...", from: "1.0.0", traits: ["Reducers"])` |

When no traits are specified, both `Dependencies` and `Reducers` are enabled by default. Specifying a trait disables defaults and enables only the traits you list.

You can also depend on the standalone umbrella products directly:

- `DependenciesExtras` — all dependency modules
- `ReducersExtras` — all reducer modules

Or import individual modules such as `Analytics`, `DeviceInfo`, or `LoggerClient`.

## Requirements

| Platform | Minimum Version |
| -------- | --------------- |
| iOS      | 16.0+           |
| macOS    | 15.0+           |
| tvOS     | 16.0+           |
| watchOS  | 9.0+            |
| Swift    | 6.3+            |
| TCA      | 1.23.1+         |

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

### AppStoreOverlay

State-driven App Store overlay presentation using TCA's `@Presents`/`ifLet` pattern. Set state to present, nil to dismiss.

```swift
// Reducer
@Presents var overlay: AppStoreOverlayReducer.State?

state.overlay = .init(appIdentifier: "1511409657")

.ifLet(\.$overlay, action: \.overlay) { AppStoreOverlayReducer() }

// View
.appStoreOverlay($store.scope(state: \.overlay, action: \.overlay))
```

> **Platform Support**: iOS only.

[Full documentation](Sources/Reducers/AppStoreOverlay/README.md)

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

### AudioPlayer

Cross-platform fire-and-forget audio playback dependency. Designed for short UI sounds and game feedback.

```swift
@Dependency(\.audioPlayer) var audioPlayer

try await audioPlayer.play(URL(string: "sound.mp3")!)
```

> **Platform Support**: iOS, macOS, tvOS, watchOS. Auto-configures `AVAudioSession` with `.ambient` category on iOS/tvOS/watchOS.

[Full documentation](Sources/Dependencies/AudioPlayer/README.md)

### DeviceInfo

A cross-platform TCA dependency for accessing device system information: CPU usage, memory, disk storage, battery, network connectivity (with interface enumeration and primary IP), thermal state, low power mode, device identity (including core counts and `isiOSAppOnMac`), screen info (resolution, scale, PPI, notch/Dynamic Island detection), jailbreak detection (iOS), hostname, boot time, system uptime, vendor identifier, and macOS-specific features (serial number, model name, software updates, password expiry, Wi-Fi SSID).

```swift
@Dependency(\.deviceInfo) var deviceInfo

let identity = await deviceInfo.identity()
let cpu = await deviceInfo.cpu()
let memory = deviceInfo.memory()
let disk = deviceInfo.disk()
let thermal = deviceInfo.thermalState()
let lowPower = deviceInfo.isLowPowerModeEnabled()

#if !os(tvOS)
let battery = await deviceInfo.battery()
#endif

#if !os(watchOS)
let network = await deviceInfo.network()
#endif

#if !os(visionOS)
let screen = await deviceInfo.screen()
#endif
```

> **Platform Support**: iOS, macOS, tvOS, watchOS. Battery excluded on tvOS, network excluded on watchOS. Screen excluded on visionOS. Jailbreak detection iOS only.

[Full documentation](Sources/Dependencies/DeviceInfo/README.md)

### LaunchAtLogin

A macOS TCA dependency for managing launch-at-login registration via `SMAppService`. Includes a ready-made SwiftUI `Toggle` view for settings screens.

```swift
@Dependency(\.launchAtLogin) var launchAtLogin

let isEnabled = launchAtLogin.isEnabled()
try launchAtLogin.setEnabled(true)

// Or use the built-in toggle in SwiftUI:
LaunchAtLoginClient.Toggle()
```

> **Platform Support**: macOS and Mac Catalyst only.

[Full documentation](Sources/Dependencies/LaunchAtLogin/README.md)

### LoggerClient

A composable logging dependency with console (`os.Logger`) and file destinations. Compose multiple log destinations via `merge()`, following the same pattern as `AnalyticsClient`.

```swift
// Setup (required):
prepareDependencies {
  $0.loggerClient = .merge(
    .console(),
    .fileLogger()
  )
}

// Usage:
@Dependency(\.loggerClient) var logger

logger.info("User logged in")
logger.error("Network request failed: \(error)")
```

Custom destinations for remote platforms (Sentry, Crashlytics, Datadog, etc.) are trivial — just implement `AppLoggerClient.init(log:)`:

```swift
extension AppLoggerClient {
  static func crashlytics() -> Self {
    .init { entry in
      Crashlytics.crashlytics().log("\(entry.message)")
      if entry.level == .error || entry.level == .fault {
        Crashlytics.crashlytics().record(
          error: NSError(domain: "AppLogger", code: 0, userInfo: [NSDebugDescriptionErrorKey: entry.message])
        )
      }
    }
  }
}

// Compose all destinations:
prepareDependencies {
  $0.loggerClient = .merge(.console(), .fileLogger(), .crashlytics(), .sentry(), .datadog())
}
```

> **Destinations**: `.console()` (os.Logger), `.fileLogger()` (actor-based with rotation), `.noop()`, or any custom destination. Custom `LogFormatter` protocol for output format.

[Full documentation](Sources/Dependencies/LoggerClient/README.md)

### OpenSettings

A cross-platform TCA dependency for opening system settings. Platform-specific enum cases ensure consumers only see options their platform supports. On macOS, supports approximately 30 system preference panes and 14 Privacy sub-panes via the `x-apple.systempreferences:` URL scheme.

```swift
@Dependency(\.openSettings) var openSettings

await openSettings.open(.general)

#if os(macOS)
await openSettings.open(.softwareUpdate)
await openSettings.open(.privacy(.fullDiskAccess))
#endif
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

### ShellClient

A macOS-only TCA dependency for executing shell commands via `/bin/zsh -c`. Returns stdout, stderr, and exit code in a `ShellResult` struct. Built on [swift-subprocess](https://github.com/swiftlang/swift-subprocess).

```swift
@Dependency(\.shellClient) var shellClient

let result = try await shellClient.run("git rev-parse --abbrev-ref HEAD")
if result.succeeded {
  // result.stdout contains the branch name
}
```

> **Platform Support**: macOS only. Compiles to an empty module on other platforms.

[Full documentation](Sources/Dependencies/ShellClient/README.md)

## Privacy Manifest

This package includes a `PrivacyInfo.xcprivacy` privacy manifest as required by Apple for third-party SDKs.

### Declared API Categories

| Category                                                       | Reason Code | Usage                                                                                                                             |
| -------------------------------------------------------------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------- |
| Disk Space (`NSPrivacyAccessedAPICategoryDiskSpace`)           | `85F4.1`    | `DeviceInfo` module queries disk capacity via `URLResourceKey` to display storage information to the user                         |
| File Timestamp (`NSPrivacyAccessedAPICategoryFileTimestamp`)   | `C617.1`    | `DeviceInfo` module's jailbreak detection (iOS only) uses `FileManager.attributesOfItem(atPath:)` which internally calls `stat()` |
| System Boot Time (`NSPrivacyAccessedAPICategorySystemBootTime`) | `35F9.1`    | `DeviceInfo` module's `bootTime` property uses `sysctl` with `CTL_KERN` + `KERN_BOOTTIME` to read the last boot timestamp        |

### For App Developers

The privacy manifest bundled with this package covers the APIs used by the package itself. If your app uses the **Analytics** module with real analytics providers (Firebase, Amplitude, etc.), you must declare any applicable `NSPrivacyCollectedDataTypes` in your **app's own** privacy manifest.

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=mehmetbaykar/swift-composable-architecture-extras&type=date&legend=top-left)](https://www.star-history.com/#mehmetbaykar/swift-composable-architecture-extras&type=date&legend=top-left)

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Acknowledgments

Built on top of [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) by [Point-Free](https://www.pointfree.co).

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
