#if os(iOS) || os(visionOS)
  import UIKit

  enum BatteryMeasurement {
    @MainActor
    static func measure() -> BatteryInfo {
      let device = UIDevice.current
      let wasEnabled = device.isBatteryMonitoringEnabled
      if !wasEnabled {
        device.isBatteryMonitoringEnabled = true
      }
      defer {
        if !wasEnabled {
          device.isBatteryMonitoringEnabled = false
        }
      }

      let level = Percentage(rawValue: Double(device.batteryLevel))
      let state: DeviceBatteryState
      switch device.batteryState {
      case .unknown: state = .unknown
      case .unplugged: state = .unplugged
      case .charging: state = .charging
      case .full: state = .full
      @unknown default: state = .unknown
      }

      return BatteryInfo(level: level, state: state)
    }
  }

#elseif os(macOS)
  import Foundation
  import IOKit

  enum BatteryMeasurement {
    static func measure() -> BatteryInfo {
      let mainPort: mach_port_t
      if #available(macOS 12.0, *) {
        mainPort = kIOMainPortDefault
      } else {
        mainPort = 0
      }
      let service = IOServiceGetMatchingService(
        mainPort,
        IOServiceNameMatching("AppleSmartBattery")
      )
      guard service != IO_OBJECT_NULL else {
        return .zero
      }
      defer {
        IOObjectRelease(service)
      }

      var props: Unmanaged<CFMutableDictionary>?
      guard
        IORegistryEntryCreateCFProperties(
          service, &props, kCFAllocatorDefault, 0
        ) == kIOReturnSuccess,
        let dict = props?.takeRetainedValue() as? [String: AnyObject]
      else {
        return .zero
      }

      let currentCapacity = dict["AppleRawCurrentCapacity"] as? Double ?? 0
      let maxCapacityRaw = dict["AppleRawMaxCapacity"] as? Double ?? 1
      let designCapacity = dict["DesignCapacity"] as? Double ?? 1
      let isCharging = (dict["IsCharging"] as? Int ?? 0) == 1
      let fullyCharged = (dict["FullyCharged"] as? Int ?? 0) == 1

      let level = Percentage(rawValue: min(currentCapacity / max(maxCapacityRaw, 1), 1.0))
      let state: DeviceBatteryState
      if fullyCharged {
        state = .full
      } else if isCharging {
        state = .charging
      } else {
        state = .unplugged
      }

      let cycleCount = dict["CycleCount"] as? Int
      let temperature: Double?
      if let raw = dict["Temperature"] as? Double {
        temperature = raw / 100.0
      } else {
        temperature = nil
      }
      let maxCapacity = Percentage(rawValue: min(maxCapacityRaw / max(designCapacity, 1), 1.0))
      let adapterName = (dict["AdapterDetails"] as? [String: AnyObject])?["Name"] as? String

      return BatteryInfo(
        level: level,
        state: state,
        cycleCount: cycleCount,
        temperature: temperature,
        maxCapacity: maxCapacity,
        adapterName: adapterName
      )
    }
  }

#elseif os(watchOS)
  import WatchKit

  enum BatteryMeasurement {
    static func measure() -> BatteryInfo {
      let device = WKInterfaceDevice.current()
      let wasEnabled = device.isBatteryMonitoringEnabled
      if !wasEnabled {
        device.isBatteryMonitoringEnabled = true
      }
      defer {
        if !wasEnabled {
          device.isBatteryMonitoringEnabled = false
        }
      }

      let level = Percentage(rawValue: Double(device.batteryLevel))
      let state: DeviceBatteryState
      switch device.batteryState {
      case .unknown: state = .unknown
      case .unplugged: state = .unplugged
      case .charging: state = .charging
      case .full: state = .full
      @unknown default: state = .unknown
      }

      return BatteryInfo(level: level, state: state)
    }
  }
#endif
