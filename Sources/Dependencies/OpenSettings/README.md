# OpenSettings

A cross-platform TCA dependency for opening system settings.

## Overview

`OpenSettingsClient` provides a testable interface for navigating users to
app-specific settings screens. Platform-specific enum cases ensure
consumers only see options their platform supports.

## Usage

### Access in a Reducer

```swift
@Dependency(\.openSettings) var openSettings

await openSettings.open(.general)

#if os(iOS) || os(macOS) || os(visionOS)
await openSettings.open(.notifications)
#endif
```

### Testing

```swift
let store = TestStore(initialState: MyFeature.State()) {
  MyFeature()
} withDependencies: {
  $0.openSettings = .noop
}
```

## Platform Support

| Platform | `.general` | `.notifications` |
|----------|-----------|-------------------|
| iOS/iPadOS | App settings | Notification settings (iOS 16+, falls back to general) |
| macOS | System Settings | Notification preferences |
| tvOS | App settings | Not available |
| visionOS | App settings | Notification settings |
| watchOS | Not available | Not available |

## API

| Property | Type | Description |
|----------|------|-------------|
| `open` | `@MainActor @Sendable (SettingsType) async -> Void` | Opens the specified settings screen |
