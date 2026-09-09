# DeviceInfo

A cross-platform TCA dependency for accessing device system information.

## Overview

`DeviceInfoClient` provides testable, one-shot access to device hardware and
system state: CPU usage (including per-core), memory (including active/inactive/wired/purgeable),
disk storage, battery, network connectivity, thermal state, low power mode,
device identity (core counts, `isiOSAppOnMac`, hardware identifier, marketing name),
screen info (resolution, scale, PPI, notch/Dynamic Island detection via
[DeviceKit](https://github.com/devicekit/DeviceKit)), jailbreak detection (iOS),
hostname, boot time, system uptime, localization, process metrics, debugger
attachment, vendor identifier, and macOS-specific features including serial number,
model name, software updates, password expiry, and Wi-Fi SSID.

## Usage

### Access in a Reducer

```swift
@Dependency(\.deviceInfo) var deviceInfo

let identity = await deviceInfo.identity()
let cpu = await deviceInfo.cpu()
let memory = deviceInfo.memory()
let disk = deviceInfo.disk()
let thermal = deviceInfo.thermalState()
let lowPower = deviceInfo.isLowPowerModeEnabled()

// Cross-platform properties
let hostname = await deviceInfo.hostname()
let bootTime = deviceInfo.bootTime()
let uptime = deviceInfo.systemUptime()
let localization = deviceInfo.localization()
let process = deviceInfo.process()
let debuggerAttached = deviceInfo.isDebuggerAttached()

#if !os(tvOS)
let battery = await deviceInfo.battery()
#endif

#if !os(watchOS)
let network = await deviceInfo.network()
let externalIP = await deviceInfo.externalIPAddress()
#endif

#if os(iOS)
let jailbreak = await deviceInfo.jailbreakStatus()
let carrier = deviceInfo.carrier()
let accessories = await deviceInfo.accessories()
let capabilities = await deviceInfo.hardwareCapabilities()
let orientation = await deviceInfo.orientation()
#endif

#if !os(visionOS)
let screen = await deviceInfo.screen()
// screen.width, screen.height, screen.scale on all platforms
// screen.nativePixelWidth, screen.nativePixelHeight on all platforms
// (physical pixels, portrait-normalized: width is the shorter edge)
// screen.diagonal, screen.ppi, screen.screenRatio on iOS/tvOS/watchOS
// screen.hasNotch, screen.hasDynamicIsland, screen.hasRoundedDisplayCorners on iOS
#endif

#if os(iOS) || os(tvOS) || os(visionOS) || os(watchOS)
let vendorID = await deviceInfo.identifierForVendor()
#endif

#if os(macOS)
let serial = deviceInfo.serialNumber()
let model = await deviceInfo.modelName()
let updates = deviceInfo.softwareUpdates()
let passwordDays = await deviceInfo.passwordExpiryDays()
let currentSSID = await deviceInfo.ssid()

// macOS version name from identity
if let versionName = identity.macOSVersionName {
  // e.g., "Sequoia" for macOS 15
}
#endif
```

### Testing

```swift
let store = TestStore(initialState: MyFeature.State()) {
  MyFeature()
} withDependencies: {
  $0.deviceInfo = .noop
}
```

## Platform Support

| Category | iOS | macOS | tvOS | watchOS |
|----------|-----|-------|------|---------|
| Identity | UIDevice | ProcessInfo + sysctl | UIDevice | WKInterfaceDevice |
| CPU | Mach host_cpu_load_info | Mach host_cpu_load_info | Mach host_cpu_load_info | task_info() |
| Memory | vm_statistics64 | vm_statistics64 | vm_statistics64 | os_proc_available_memory |
| Disk | URLResourceValues | URLResourceValues | URLResourceValues | URLResourceValues |
| Battery | UIDevice | IOKit (rich) | N/A | WKInterfaceDevice |
| Network | NWPathMonitor | NWPathMonitor | NWPathMonitor | N/A |
| Thermal | ProcessInfo | ProcessInfo | ProcessInfo | ProcessInfo |
| Screen | DeviceKit + UIScreen | NSScreen | DeviceKit + UIScreen | DeviceKit + WKInterfaceDevice |
| Jailbreak | Filesystem + Sandbox + Dyld + Env | N/A | N/A | N/A |
| Hostname | UIDevice.current.name | Host.current().localizedName | UIDevice.current.name | WKInterfaceDevice.current().name |
| Boot Time | sysctl (CTL_KERN + KERN_BOOTTIME) | sysctl (CTL_KERN + KERN_BOOTTIME) | sysctl (CTL_KERN + KERN_BOOTTIME) | sysctl (CTL_KERN + KERN_BOOTTIME) |
| System Uptime | ProcessInfo.systemUptime | ProcessInfo.systemUptime | ProcessInfo.systemUptime | ProcessInfo.systemUptime |
| Identifier for Vendor | UIDevice | N/A | UIDevice | WKInterfaceDevice |
| Localization | Locale | Locale | Locale | Locale |
| Process | getpid + task_threads | getpid + task_threads | getpid + task_threads | getpid + task_threads |
| Debugger | sysctl P_TRACED | sysctl P_TRACED | sysctl P_TRACED | sysctl P_TRACED |
| External IP | icanhazip.com | icanhazip.com | icanhazip.com | N/A |
| Carrier | CoreTelephony | N/A | N/A | N/A |
| Accessories | AVAudioSession + EAAccessory | N/A | N/A | N/A |
| Hardware capabilities | UIDevice + CMPedometer | N/A | N/A | N/A |
| Orientation | UIWindowScene | N/A | N/A | N/A |
| Serial Number | N/A | IOKit (IOPlatformExpertDevice) | N/A | N/A |
| Model Name | N/A | ioreg (Apple Silicon) / Apple API (Intel) | N/A | N/A |
| Software Updates | N/A | com.apple.SoftwareUpdate domain | N/A | N/A |
| Password Expiry | N/A | OpenDirectory (ODRecord) | N/A | N/A |
| SSID | N/A | CoreWLAN | N/A | N/A |

## API

| Property | Type | Description |
|----------|------|-------------|
| `identity` | `@Sendable () async -> DeviceIdentity` | Device name, model, OS name/version, core counts, isiOSAppOnMac, modelIdentifier, marketingName |
| `isLowPowerModeEnabled` | `@Sendable () -> Bool` | Low Power Mode state (false on macOS < 12) |
| `cpu` | `@Sendable () async -> CPUInfo` | CPU usage (100ms measurement) plus `perCoreUsage` |
| `memory` | `@Sendable () -> MemoryInfo` | RAM usage, total, used, available, active, inactive, wired, purgeable |
| `disk` | `@Sendable () -> DiskInfo` | Disk usage, total, used, available |
| `thermalState` | `@Sendable () -> DeviceThermalState` | Thermal state (nominal/fair/serious/critical) |
| `hostname` | `@Sendable () async -> String` | User-assigned device name |
| `bootTime` | `@Sendable () -> Date` | Date of last device boot (sysctl) |
| `systemUptime` | `@Sendable () -> TimeInterval` | Seconds since last wake (excludes sleep) |
| `battery` | `@Sendable () async -> BatteryInfo` | Battery level and state (not tvOS) |
| `network` | `@Sendable () async -> NetworkInfo` | Connectivity, interface type, IP addresses (not watchOS) |
| `screen` | `@Sendable () async -> ScreenInfo` | Screen resolution (points + native pixels), scale, PPI, notch detection (not visionOS) |
| `jailbreakStatus` | `@Sendable () async -> JailbreakStatus` | Jailbreak confidence level (iOS only) |
| `identifierForVendor` | `@Sendable () async -> UUID?` | Vendor-scoped device UUID (iOS, tvOS, visionOS, watchOS) |
| `localization` | `@Sendable () -> LocalizationInfo` | Locale, language, region, time zone, currency |
| `process` | `@Sendable () -> ProcessMetrics` | Current process ID and this process's CPU usage |
| `isDebuggerAttached` | `@Sendable () -> Bool` | Whether a debugger is attached to this process |
| `externalIPAddress` | `@Sendable () async -> String?` | Public IP via HTTPS to icanhazip.com (not watchOS) |
| `carrier` | `@Sendable () -> CarrierInfo` | Cellular carrier and radio (iOS; nil placeholders on iOS 16.4+) |
| `accessories` | `@Sendable () async -> AccessoryInfo` | Headphones and MFi accessories (iOS) |
| `hardwareCapabilities` | `@Sendable () async -> HardwareCapabilities` | Proximity and pedometer availability (iOS) |
| `orientation` | `@Sendable () async -> DeviceInterfaceOrientation` | Foreground scene orientation (iOS) |
| `serialNumber` | `@Sendable () -> String` | Hardware serial number (macOS only) |
| `modelName` | `@Sendable () async -> ModelNameInfo` | Marketing name and metadata (macOS only) |
| `softwareUpdates` | `@Sendable () -> [SoftwareUpdateInfo]` | Pending macOS software updates (macOS only) |
| `passwordExpiryDays` | `@Sendable () async -> Int?` | Days until password expires (macOS only) |
| `ssid` | `@Sendable () async -> String?` | Current Wi-Fi SSID (macOS only) |

## Jailbreak Detection

The `jailbreakStatus` endpoint (iOS only) performs multiple security checks and returns a confidence-based result. This is a security-awareness feature -- not a bulletproof solution, as client-side detection is inherently bypassable.

**Checks performed**: filesystem artifact scanning, sandbox integrity testing, loaded library enumeration (`_dyld_image_count`), and environment variable inspection.

**Confidence levels**: `.nominal` (clean), `.low` (weak indicators), `.moderate` (filesystem or sandbox issues), `.high` (substrate/tweaks + multiple indicators).

> **Note**: On simulators, `jailbreakStatus` always returns `.nominal`. Consumers decide their own threshold -- no `isJailbroken` boolean is provided.

## macOS System Information

### Model Name

`modelName` returns a `ModelNameInfo` struct with the marketing name, short name, model identifier, year (Intel only), and an SF Symbol name for the device icon.

- **Apple Silicon**: Resolved locally via `ioreg` data. The `marketingName` is the product line (e.g., "MacBook Pro").
- **Intel Macs**: Resolved via Apple's `support-sp.apple.com` API using the serial number. Includes the model year (e.g., "MacBook Pro (Late 2021)").
- **Cached**: The result is cached in memory after the first call.

### Software Updates

`softwareUpdates` returns an array of `SoftwareUpdateInfo` values read from the `com.apple.SoftwareUpdate` user defaults domain. Each entry includes the display name, version, whether it is a major update, and the product key.

### Password Expiry

`passwordExpiryDays` uses OpenDirectory (`ODRecord.secondsUntilPasswordExpires`) to determine when the local user account password will expire. Returns `nil` if no password policy is configured.

## Network Identity

The `NetworkInfo` struct includes extended network identity fields:

| Property | Type | Description |
|----------|------|-------------|
| `isConnected` | `Bool` | Whether the device has an active connection |
| `interfaceType` | `NetworkInterfaceType` | Primary interface type (wifi, cellular, wiredEthernet, loopback, unknown) |
| `primaryIPAddress` | `String?` | IPv4 address of the primary active non-loopback interface |
| `interfaces` | `[NetworkInterface]` | All detected interfaces with name, IP, IPv6, netmask, broadcast, type, and active status |
| `isConnectedToWiFi` | `Bool` | Primary path is Wi-Fi |
| `isConnectedToCellular` | `Bool` | Primary path is cellular |
| `wifiIPAddress` | `String?` | IPv4 of the first active Wi-Fi interface |
| `cellularIPAddress` | `String?` | IPv4 of the first active cellular interface |

The `ssid` property on `DeviceInfoClient` (macOS only) provides the SSID of the currently connected Wi-Fi network via CoreWLAN, separate from the `network` property.

`externalIPAddress` performs an HTTPS request to `icanhazip.com` and returns `nil` when offline or the response is not an IP address.

## Notes

- **iOS hostname entitlement**: On iOS 16+, `UIDevice.current.name` returns a generic device name (e.g., "iPhone") unless the app has the `com.apple.developer.device-information.user-assigned-device-name` entitlement. The `hostname` property reflects this behavior.
- **SSID and Location Services**: On macOS 14+, reading the SSID via CoreWLAN requires Location Services permission. Returns `nil` if permission is not granted.
- **identifierForVendor reset**: The UUID returned by `identifierForVendor` resets when all apps from the same vendor are deleted from the device. Returns `nil` before the first device unlock after restart.
- **macOSVersionName**: `DeviceIdentity` includes a computed `macOSVersionName` property (macOS only) that maps the major version number to the marketing name (e.g., 15 = "Sequoia", 16 = "Tahoe"). Returns `nil` for unrecognized versions.
- **System boot time**: Uses `sysctl` with `CTL_KERN` + `KERN_BOOTTIME` on all platforms. This is the wall-clock time of the last boot, not affected by clock changes.
- **System uptime**: Uses `ProcessInfo.processInfo.systemUptime`, which counts only awake time (sleep duration is excluded).
- **Carrier on iOS 16.4+**: `CTCarrier` returns placeholder values for third-party apps. `CarrierInfo` maps `"--"`, `"65535"`, and `"00000"` to `nil`. `radioAccessTechnology` still reflects the current radio when registered.
- **Not ported from iOS-System-Services**: clipboard contents, random CFUUID, Core Motion streams, app version (`AppInfo`), screen brightness (`ScreenBrightness`), and Wi-Fi router address (private routing headers).
