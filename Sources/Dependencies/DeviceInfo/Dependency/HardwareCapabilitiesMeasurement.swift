#if os(iOS)

  import CoreMotion
  import UIKit

  enum HardwareCapabilitiesMeasurement {
    @MainActor
    static func measure() -> HardwareCapabilities {
      HardwareCapabilities(
        isProximitySensorAvailable: isProximitySensorAvailable(),
        isStepCountingAvailable: CMPedometer.isStepCountingAvailable(),
        isDistanceAvailable: CMPedometer.isDistanceAvailable(),
        isFloorCountingAvailable: CMPedometer.isFloorCountingAvailable()
      )
    }

    @MainActor
    private static func isProximitySensorAvailable() -> Bool {
      let device = UIDevice.current
      let wasEnabled = device.isProximityMonitoringEnabled
      if !wasEnabled {
        device.isProximityMonitoringEnabled = true
      }
      let available = device.isProximityMonitoringEnabled
      if !wasEnabled {
        device.isProximityMonitoringEnabled = false
      }
      return available
    }
  }

#endif
