import Dependencies
import Foundation

#if os(iOS)
  import UIKit

  extension DeviceInfoClient: DependencyKey {
    public static var liveValue: DeviceInfoClient {
      .init(
        identity: {
          await MainActor.run {
            let device = UIDevice.current
            let isiOSAppOnMac: Bool = {
              if #available(iOS 14.0, *) {
                return ProcessInfo.processInfo.isiOSAppOnMac
              }
              return false
            }()
            return DeviceIdentity(
              name: device.name,
              model: device.model,
              systemName: device.systemName,
              systemVersion: device.systemVersion,
              totalCoreCount: ProcessInfo.processInfo.processorCount,
              activeCoreCount: ProcessInfo.processInfo.activeProcessorCount,
              isiOSAppOnMac: isiOSAppOnMac
            )
          }
        },
        cpu: { await CPUMeasurement.measure() },
        memory: { MemoryMeasurement.measure() },
        disk: { DiskMeasurement.measure() },
        thermalState: {
          DeviceThermalState(processInfoState: ProcessInfo.processInfo.thermalState)
        },
        isLowPowerModeEnabled: {
          ProcessInfo.processInfo.isLowPowerModeEnabled
        },
        battery: {
          await MainActor.run { BatteryMeasurement.measure() }
        },
        network: { await NetworkMeasurement.measure() },
        jailbreakStatus: { JailbreakMeasurement.measure() }
      )
    }
  }

#elseif os(visionOS)
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
              systemVersion: device.systemVersion,
              totalCoreCount: ProcessInfo.processInfo.processorCount,
              activeCoreCount: ProcessInfo.processInfo.activeProcessorCount,
              isiOSAppOnMac: ProcessInfo.processInfo.isiOSAppOnMac
            )
          }
        },
        cpu: { await CPUMeasurement.measure() },
        memory: { MemoryMeasurement.measure() },
        disk: { DiskMeasurement.measure() },
        thermalState: {
          DeviceThermalState(processInfoState: ProcessInfo.processInfo.thermalState)
        },
        isLowPowerModeEnabled: {
          ProcessInfo.processInfo.isLowPowerModeEnabled
        },
        battery: {
          await MainActor.run { BatteryMeasurement.measure() }
        },
        network: { await NetworkMeasurement.measure() }
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
          let isiOSAppOnMac: Bool = {
            if #available(macOS 11.0, *) {
              return processInfo.isiOSAppOnMac
            }
            return false
          }()
          return DeviceIdentity(
            name: processInfo.hostName,
            model: model,
            systemName: "macOS",
            systemVersion: processInfo.operatingSystemVersionString,
            totalCoreCount: processInfo.processorCount,
            activeCoreCount: processInfo.activeProcessorCount,
            isiOSAppOnMac: isiOSAppOnMac
          )
        },
        cpu: { await CPUMeasurement.measure() },
        memory: { MemoryMeasurement.measure() },
        disk: { DiskMeasurement.measure() },
        thermalState: {
          DeviceThermalState(processInfoState: ProcessInfo.processInfo.thermalState)
        },
        isLowPowerModeEnabled: {
          if #available(macOS 12.0, *) {
            return ProcessInfo.processInfo.isLowPowerModeEnabled
          }
          return false
        },
        battery: { BatteryMeasurement.measure() },
        network: { await NetworkMeasurement.measure() }
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
            let isiOSAppOnMac: Bool = {
              if #available(tvOS 14.0, *) {
                return ProcessInfo.processInfo.isiOSAppOnMac
              }
              return false
            }()
            return DeviceIdentity(
              name: device.name,
              model: device.model,
              systemName: device.systemName,
              systemVersion: device.systemVersion,
              totalCoreCount: ProcessInfo.processInfo.processorCount,
              activeCoreCount: ProcessInfo.processInfo.activeProcessorCount,
              isiOSAppOnMac: isiOSAppOnMac
            )
          }
        },
        cpu: { await CPUMeasurement.measure() },
        memory: { MemoryMeasurement.measure() },
        disk: { DiskMeasurement.measure() },
        thermalState: {
          DeviceThermalState(processInfoState: ProcessInfo.processInfo.thermalState)
        },
        isLowPowerModeEnabled: {
          ProcessInfo.processInfo.isLowPowerModeEnabled
        },
        network: { await NetworkMeasurement.measure() }
      )
    }
  }

#elseif os(watchOS)
  import WatchKit

  extension DeviceInfoClient: DependencyKey {
    public static var liveValue: DeviceInfoClient {
      .init(
        identity: {
          await MainActor.run {
            let device = WKInterfaceDevice.current()
            let isiOSAppOnMac: Bool = {
              if #available(watchOS 7.0, *) {
                return ProcessInfo.processInfo.isiOSAppOnMac
              }
              return false
            }()
            return DeviceIdentity(
              name: device.name,
              model: device.model,
              systemName: device.systemName,
              systemVersion: device.systemVersion,
              totalCoreCount: ProcessInfo.processInfo.processorCount,
              activeCoreCount: ProcessInfo.processInfo.activeProcessorCount,
              isiOSAppOnMac: isiOSAppOnMac
            )
          }
        },
        cpu: { await CPUMeasurement.measure() },
        memory: { MemoryMeasurement.measure() },
        disk: { DiskMeasurement.measure() },
        thermalState: {
          DeviceThermalState(processInfoState: ProcessInfo.processInfo.thermalState)
        },
        isLowPowerModeEnabled: {
          ProcessInfo.processInfo.isLowPowerModeEnabled
        },
        battery: { BatteryMeasurement.measure() }
      )
    }
  }
#endif
