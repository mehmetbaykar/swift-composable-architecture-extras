# DeviceInfo

A cross-platform TCA dependency for accessing device system information.

## Overview

`DeviceInfoClient` provides testable, one-shot access to device hardware and
system state: CPU usage, memory, disk storage, battery, network connectivity,
thermal state, low power mode, device identity (including core counts and
`isiOSAppOnMac`), screen info (resolution, scale, PPI, notch/Dynamic Island
detection via [DeviceKit](https://github.com/devicekit/DeviceKit)), and
jailbreak detection (iOS).

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

#if !os(tvOS)
let battery = await deviceInfo.battery()
#endif

#if !os(watchOS)
let network = await deviceInfo.network()
#endif

#if os(iOS)
let jailbreak = await deviceInfo.jailbreakStatus()
if jailbreak.confidence >= .moderate {
  // Handle potentially compromised device
}
#endif

#if !os(visionOS)
let screen = await deviceInfo.screen()
// screen.width, screen.height, screen.scale on all platforms
// screen.diagonal, screen.ppi, screen.screenRatio on iOS/tvOS/watchOS
// screen.hasNotch, screen.hasDynamicIsland, screen.hasRoundedDisplayCorners on iOS
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

## API

| Property | Type | Description |
|----------|------|-------------|
| `identity` | `@Sendable () async -> DeviceIdentity` | Device name, model, OS name/version, core counts, isiOSAppOnMac |
| `isLowPowerModeEnabled` | `@Sendable () -> Bool` | Low Power Mode state (false on macOS < 12) |
| `cpu` | `@Sendable () async -> CPUInfo` | CPU usage (100ms measurement) |
| `memory` | `@Sendable () -> MemoryInfo` | RAM usage, total, used, available |
| `disk` | `@Sendable () -> DiskInfo` | Disk usage, total, used, available |
| `thermalState` | `@Sendable () -> DeviceThermalState` | Thermal state (nominal/fair/serious/critical) |
| `battery` | `@Sendable () async -> BatteryInfo` | Battery level and state (not tvOS) |
| `network` | `@Sendable () async -> NetworkInfo` | Connectivity and interface type (not watchOS) |
| `screen` | `@Sendable () async -> ScreenInfo` | Screen resolution, scale, PPI, notch detection (not visionOS) |
| `jailbreakStatus` | `@Sendable () async -> JailbreakStatus` | Jailbreak confidence level (iOS only) |

## Jailbreak Detection

The `jailbreakStatus` endpoint (iOS only) performs multiple security checks and returns a confidence-based result. This is a security-awareness feature — not a bulletproof solution, as client-side detection is inherently bypassable.

**Checks performed**: filesystem artifact scanning, sandbox integrity testing, loaded library enumeration (`_dyld_image_count`), and environment variable inspection.

**Confidence levels**: `.nominal` (clean), `.low` (weak indicators), `.moderate` (filesystem or sandbox issues), `.high` (substrate/tweaks + multiple indicators).

> **Note**: On simulators, `jailbreakStatus` always returns `.nominal`. Consumers decide their own threshold — no `isJailbroken` boolean is provided.
