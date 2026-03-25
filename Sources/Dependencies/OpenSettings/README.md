# OpenSettings

A cross-platform TCA dependency for opening system settings.

## Overview

`OpenSettingsClient` provides a testable interface for navigating users to
app-specific settings screens. Platform-specific enum cases ensure
consumers only see options their platform supports.

On macOS, the client supports approximately 30 system preference panes and
14 Privacy sub-panes, all accessible via the `x-apple.systempreferences:`
URL scheme. On iOS/visionOS, it navigates to the app's settings bundle
or notification settings. On tvOS, it opens the app's general settings.

## Usage

### Access in a Reducer

```swift
@Dependency(\.openSettings) var openSettings

await openSettings.open(.general)

#if os(iOS) || os(macOS) || os(visionOS)
await openSettings.open(.notifications)
#endif
```

### macOS Usage

On macOS, a wide range of system preference panes are available:

```swift
#if os(macOS)
@Dependency(\.openSettings) var openSettings

// System information
await openSettings.open(.about)
await openSettings.open(.softwareUpdate)

// Network and connectivity
await openSettings.open(.network)
await openSettings.open(.wifi)
await openSettings.open(.bluetooth)

// Hardware
await openSettings.open(.displays)
await openSettings.open(.sound)
await openSettings.open(.keyboard)
await openSettings.open(.trackpad)
await openSettings.open(.mouse)
await openSettings.open(.printers)
await openSettings.open(.battery)

// Privacy and security
await openSettings.open(.security)
await openSettings.open(.privacy(.fullDiskAccess))
await openSettings.open(.privacy(.camera))
await openSettings.open(.privacy(.screenRecording))

// Appearance and desktop
await openSettings.open(.appearance)
await openSettings.open(.desktopAndDock)
await openSettings.open(.wallpaper)
await openSettings.open(.screenSaver)

// Accounts and identity
await openSettings.open(.appleID)
await openSettings.open(.passwords)
await openSettings.open(.users)
await openSettings.open(.familySharing)

// Other
await openSettings.open(.storage)
await openSettings.open(.accessibility)
await openSettings.open(.spotlight)
await openSettings.open(.siri)
await openSettings.open(.dateAndTime)
await openSettings.open(.sharing)
await openSettings.open(.screenTime)
await openSettings.open(.focusModes)
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

## macOS Panes

All macOS panes use the `x-apple.systempreferences:` URL scheme.

| Case | Description |
|------|-------------|
| `.general` | Opens System Settings (main window) |
| `.notifications` | Notification preferences for the current app (uses bundle ID) |
| `.about` | About This Mac / System Information |
| `.network` | Network settings |
| `.wifi` | Wi-Fi settings |
| `.bluetooth` | Bluetooth settings |
| `.sound` | Sound input/output settings |
| `.displays` | Display resolution and arrangement |
| `.storage` | Storage management |
| `.softwareUpdate` | macOS software update |
| `.accessibility` | Accessibility features |
| `.security` | Security and privacy settings |
| `.keyboard` | Keyboard settings |
| `.trackpad` | Trackpad settings |
| `.mouse` | Mouse settings |
| `.printers` | Printers and scanners |
| `.battery` | Battery and energy settings |
| `.dateAndTime` | Date and time settings |
| `.sharing` | Sharing and file sharing |
| `.users` | Users and groups |
| `.spotlight` | Spotlight and Siri settings |
| `.siri` | Siri settings (same pane as Spotlight) |
| `.desktopAndDock` | Desktop and Dock settings |
| `.wallpaper` | Wallpaper settings |
| `.screenSaver` | Screen saver settings |
| `.passwords` | Password and account security |
| `.appleID` | Apple ID account settings |
| `.familySharing` | Family Sharing settings |
| `.screenTime` | Screen Time settings |
| `.focusModes` | Focus modes settings |
| `.appearance` | Appearance (light/dark mode, accent color) |

## macOS Privacy Sub-Panes

Access privacy sub-panes via `.privacy(_:)`:

| Case | Description |
|------|-------------|
| `.privacy(.location)` | Location Services |
| `.privacy(.camera)` | Camera access |
| `.privacy(.microphone)` | Microphone access |
| `.privacy(.photos)` | Photos library access |
| `.privacy(.contacts)` | Contacts access |
| `.privacy(.calendars)` | Calendars access |
| `.privacy(.reminders)` | Reminders access |
| `.privacy(.fullDiskAccess)` | Full Disk Access |
| `.privacy(.accessibility)` | Accessibility API access |
| `.privacy(.inputMonitoring)` | Input monitoring (keystroke access) |
| `.privacy(.screenRecording)` | Screen recording and capture |
| `.privacy(.automation)` | Automation (AppleScript/Accessibility control) |
| `.privacy(.developerTools)` | Developer tools access |
| `.privacy(.analytics)` | Analytics and improvements data sharing |

## API

| Property | Type | Description |
|----------|------|-------------|
| `open` | `@MainActor @Sendable (SettingsType) async -> Void` | Opens the specified settings screen |
