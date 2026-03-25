#if !os(watchOS)

  /// Network connectivity and identity information for the device.
  public struct NetworkInfo: Sendable, Equatable {
    /// Whether the device has an active network connection.
    public let isConnected: Bool

    /// The primary network interface type.
    public let interfaceType: NetworkInterfaceType

    /// The IPv4 address of the primary active non-loopback interface, if any.
    public let primaryIPAddress: String?

    /// All detected network interfaces with their IP addresses and types.
    public let interfaces: [NetworkInterface]

    public init(
      isConnected: Bool,
      interfaceType: NetworkInterfaceType,
      primaryIPAddress: String? = nil,
      interfaces: [NetworkInterface] = []
    ) {
      self.isConnected = isConnected
      self.interfaceType = interfaceType
      self.primaryIPAddress = primaryIPAddress
      self.interfaces = interfaces
    }

    /// A default value representing a disconnected state.
    public static let disconnected = NetworkInfo(
      isConnected: false,
      interfaceType: .unknown,
      primaryIPAddress: nil,
      interfaces: []
    )
  }

  /// The type of network interface connection.
  public enum NetworkInterfaceType: Sendable, Equatable {
    case wifi
    case cellular
    case wiredEthernet
    case loopback
    case unknown
  }

#endif
