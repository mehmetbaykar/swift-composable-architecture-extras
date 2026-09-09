#if os(iOS)

  public struct AccessoryInfo: Sendable, Equatable {
    public let isHeadphonesConnected: Bool
    public let connectedAccessories: [String]

    public init(
      isHeadphonesConnected: Bool,
      connectedAccessories: [String] = []
    ) {
      self.isHeadphonesConnected = isHeadphonesConnected
      self.connectedAccessories = connectedAccessories
    }

    public var isAnyAccessoryConnected: Bool {
      isHeadphonesConnected || !connectedAccessories.isEmpty
    }

    public static let none = AccessoryInfo(isHeadphonesConnected: false)
  }

#endif
