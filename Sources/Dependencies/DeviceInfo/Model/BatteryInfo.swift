#if !os(tvOS)

  public struct BatteryInfo: Sendable, Equatable {
    public let level: Percentage
    public let state: DeviceBatteryState

    #if os(macOS)
      public let cycleCount: Int?
      public let temperature: Double?
      public let maxCapacity: Percentage?
      public let adapterName: String?

      public init(
        level: Percentage,
        state: DeviceBatteryState,
        cycleCount: Int? = nil,
        temperature: Double? = nil,
        maxCapacity: Percentage? = nil,
        adapterName: String? = nil
      ) {
        self.level = level
        self.state = state
        self.cycleCount = cycleCount
        self.temperature = temperature
        self.maxCapacity = maxCapacity
        self.adapterName = adapterName
      }

      public static let zero = BatteryInfo(level: .zero, state: .unknown)
    #else
      public init(level: Percentage, state: DeviceBatteryState) {
        self.level = level
        self.state = state
      }

      public static let zero = BatteryInfo(level: .zero, state: .unknown)
    #endif
  }

  public enum DeviceBatteryState: Sendable, Equatable {
    case unknown
    case unplugged
    case charging
    case full
  }

#endif
