#if !os(watchOS)

  public struct NetworkInfo: Sendable, Equatable {
    public let isConnected: Bool
    public let interfaceType: NetworkInterfaceType

    public init(isConnected: Bool, interfaceType: NetworkInterfaceType) {
      self.isConnected = isConnected
      self.interfaceType = interfaceType
    }

    public static let disconnected = NetworkInfo(
      isConnected: false,
      interfaceType: .unknown
    )
  }

  public enum NetworkInterfaceType: Sendable, Equatable {
    case wifi
    case cellular
    case wiredEthernet
    case loopback
    case unknown
  }

#endif
