# DeviceInfo

A cross-platform TCA dependency for accessing device system information.

## Overview

`DeviceInfoClient` provides testable, one-shot access to device hardware and
system state: CPU usage, memory, disk storage, battery, network connectivity,
thermal state, and device identity.

## Usage

### Access in a Reducer

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
let network = await deviceInfo.network()
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

## API

| Property | Type | Description |
|----------|------|-------------|
| `identity` | `@Sendable () async -> DeviceIdentity` | Device name, model, OS name/version |
| `cpu` | `@Sendable () async -> CPUInfo` | CPU usage (100ms measurement) |
| `memory` | `@Sendable () -> MemoryInfo` | RAM usage, total, used, available |
| `disk` | `@Sendable () -> DiskInfo` | Disk usage, total, used, available |
| `thermalState` | `@Sendable () -> DeviceThermalState` | Thermal state (nominal/fair/serious/critical) |
| `battery` | `@Sendable () async -> BatteryInfo` | Battery level and state (not tvOS) |
| `network` | `@Sendable () async -> NetworkInfo` | Connectivity and interface type (not watchOS) |
