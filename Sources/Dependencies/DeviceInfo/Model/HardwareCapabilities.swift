#if os(iOS)

  public struct HardwareCapabilities: Sendable, Equatable {
    public let isProximitySensorAvailable: Bool
    public let isStepCountingAvailable: Bool
    public let isDistanceAvailable: Bool
    public let isFloorCountingAvailable: Bool

    public init(
      isProximitySensorAvailable: Bool,
      isStepCountingAvailable: Bool,
      isDistanceAvailable: Bool,
      isFloorCountingAvailable: Bool
    ) {
      self.isProximitySensorAvailable = isProximitySensorAvailable
      self.isStepCountingAvailable = isStepCountingAvailable
      self.isDistanceAvailable = isDistanceAvailable
      self.isFloorCountingAvailable = isFloorCountingAvailable
    }

    public static let none = HardwareCapabilities(
      isProximitySensorAvailable: false,
      isStepCountingAvailable: false,
      isDistanceAvailable: false,
      isFloorCountingAvailable: false
    )
  }

#endif
