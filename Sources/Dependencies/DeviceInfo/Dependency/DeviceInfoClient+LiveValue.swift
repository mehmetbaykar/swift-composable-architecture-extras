import Dependencies
import Foundation

#if os(iOS) || os(visionOS)
  import UIKit

  extension DeviceInfoClient: DependencyKey {
    public static var liveValue: DeviceInfoClient {
      .init(
        identity: {
          await MainActor.run {
            let device = UIDevice.current
            return DeviceIdentity(
              name: device.name,
              model: device.model,
              systemName: device.systemName,
              systemVersion: device.systemVersion
            )
          }
        },
        cpu: { await CPUMeasurement.measure() },
        memory: { MemoryMeasurement.measure() },
        disk: { DiskMeasurement.measure() },
        thermalState: {
          DeviceThermalState(processInfoState: ProcessInfo.processInfo.thermalState)
        },
        battery: {
          await MainActor.run { BatteryMeasurement.measure() }
        },
        network: { NetworkMeasurement.measure() }
      )
    }
  }

#elseif os(macOS)

  extension DeviceInfoClient: DependencyKey {
    public static var liveValue: DeviceInfoClient {
      .init(
        identity: {
          let processInfo = ProcessInfo.processInfo
          var systemInfo = utsname()
          uname(&systemInfo)
          let model = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
              String(validatingCString: $0) ?? "Mac"
            }
          }
          return DeviceIdentity(
            name: processInfo.hostName,
            model: model,
            systemName: "macOS",
            systemVersion: processInfo.operatingSystemVersionString
          )
        },
        cpu: { await CPUMeasurement.measure() },
        memory: { MemoryMeasurement.measure() },
        disk: { DiskMeasurement.measure() },
        thermalState: {
          DeviceThermalState(processInfoState: ProcessInfo.processInfo.thermalState)
        },
        battery: { BatteryMeasurement.measure() },
        network: { NetworkMeasurement.measure() }
      )
    }
  }

#elseif os(tvOS)
  import UIKit

  extension DeviceInfoClient: DependencyKey {
    public static var liveValue: DeviceInfoClient {
      .init(
        identity: {
          await MainActor.run {
            let device = UIDevice.current
            return DeviceIdentity(
              name: device.name,
              model: device.model,
              systemName: device.systemName,
              systemVersion: device.systemVersion
            )
          }
        },
        cpu: { await CPUMeasurement.measure() },
        memory: { MemoryMeasurement.measure() },
        disk: { DiskMeasurement.measure() },
        thermalState: {
          DeviceThermalState(processInfoState: ProcessInfo.processInfo.thermalState)
        },
        network: { NetworkMeasurement.measure() }
      )
    }
  }

#elseif os(watchOS)
  import WatchKit

  extension DeviceInfoClient: DependencyKey {
    public static var liveValue: DeviceInfoClient {
      .init(
        identity: {
          let device = WKInterfaceDevice.current()
          return DeviceIdentity(
            name: device.name,
            model: device.model,
            systemName: device.systemName,
            systemVersion: device.systemVersion
          )
        },
        cpu: { await CPUMeasurement.measure() },
        memory: { MemoryMeasurement.measure() },
        disk: { DiskMeasurement.measure() },
        thermalState: {
          DeviceThermalState(processInfoState: ProcessInfo.processInfo.thermalState)
        },
        battery: { BatteryMeasurement.measure() }
      )
    }
  }
#endif
