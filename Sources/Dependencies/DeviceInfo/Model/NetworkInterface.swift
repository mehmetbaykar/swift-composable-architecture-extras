#if !os(watchOS)

  /// A detected network interface with its IP address and connection type.
  public struct NetworkInterface: Sendable, Equatable, Identifiable {
    /// The system interface name (e.g., "en0", "en1", "pdp_ip0").
    public let id: String

    /// The system interface name, same as `id`.
    public let name: String

    /// The IPv4 address assigned to this interface.
    public let ipAddress: String

    /// The detected connection type based on interface name conventions.
    public let type: NetworkInterfaceType

    /// Whether this interface is currently active (UP and RUNNING).
    public let isActive: Bool

    public init(
      name: String,
      ipAddress: String,
      type: NetworkInterfaceType,
      isActive: Bool
    ) {
      self.id = name
      self.name = name
      self.ipAddress = ipAddress
      self.type = type
      self.isActive = isActive
    }
  }

#endif
