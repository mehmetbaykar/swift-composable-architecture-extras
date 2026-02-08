# OpenURL

A cross-platform TCA dependency for opening URLs externally or in-app via SFSafariViewController.

## Overview

`OpenURLClient` provides a testable interface for opening URLs. On iOS, it supports
both external browser opening and in-app browsing via `SFSafariViewController`.
Other platforms open URLs in the default browser.

Uses `\.customOpenURL` key path to avoid shadowing TCA's built-in `\.openURL`.

## Usage

### Open URL Externally

```swift
@Dependency(\.customOpenURL) var openURL

await openURL(URL(string: "https://example.com")!)
```

### Open URL In-App (iOS Only)

```swift
#if os(iOS)
@Dependency(\.customOpenURL) var openURL

await openURL(URL(string: "https://example.com")!, prefersInApp: true)
#endif
```

### Direct Closure Access

```swift
@Dependency(\.customOpenURL) var openURL

let success = await openURL.open(url)

#if os(iOS)
let presented = await openURL.openInApp(url)
#endif
```

### Testing

```swift
let store = TestStore(initialState: MyFeature.State()) {
  MyFeature()
} withDependencies: {
  $0.customOpenURL = .noop
}
```

## Platform Support

| Platform | `open` (external) | `openInApp` (SFSafariViewController) |
|----------|-------------------|--------------------------------------|
| iOS | `UIApplication.shared.open` | SFSafariViewController via topmost VC |
| macOS | `NSWorkspace.shared.open` | Not available |
| tvOS | `UIApplication.shared.open` | Not available |
| visionOS | `UIApplication.shared.open` | Not available |
| watchOS | Not available | Not available |

## API

| Property | Type | Platforms | Description |
|----------|------|-----------|-------------|
| `open` | `@MainActor @Sendable (URL) async -> Bool` | All (except watchOS) | Opens URL in external browser |
| `openInApp` | `@MainActor @Sendable (URL) async -> Bool` | iOS only | Presents SFSafariViewController |
| `callAsFunction(_:)` | `(URL) async -> Bool` | All (except watchOS) | Shorthand for `open` |
| `callAsFunction(_:prefersInApp:)` | `(URL, Bool) async -> Bool` | iOS only | Dispatches to `openInApp` or `open` |
