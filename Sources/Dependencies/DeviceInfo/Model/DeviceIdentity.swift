/// Identifying information about the device including name, model, and system version.
public struct DeviceIdentity: Sendable, Equatable {
  /// The user-assigned device name.
  public let name: String

  /// The device model string.
  public let model: String

  /// The operating system name (e.g., "iOS", "macOS").
  public let systemName: String

  /// The operating system version string (e.g., "18.0", "15.4").
  public let systemVersion: String

  /// Total number of CPU cores on the device.
  public let totalCoreCount: Int

  /// Number of currently active CPU cores.
  public let activeCoreCount: Int

  /// Whether this is an iOS app running on a Mac via Mac Catalyst or Apple Silicon.
  public let isiOSAppOnMac: Bool

  public init(
    name: String,
    model: String,
    systemName: String,
    systemVersion: String,
    totalCoreCount: Int,
    activeCoreCount: Int,
    isiOSAppOnMac: Bool
  ) {
    self.name = name
    self.model = model
    self.systemName = systemName
    self.systemVersion = systemVersion
    self.totalCoreCount = totalCoreCount
    self.activeCoreCount = activeCoreCount
    self.isiOSAppOnMac = isiOSAppOnMac
  }

  #if os(macOS)
    /// The macOS marketing version name (e.g., "Sequoia" for macOS 15).
    ///
    /// Returns `nil` for unrecognized version numbers.
    public var macOSVersionName: String? {
      guard let major = Int(systemVersion.components(separatedBy: ".").first ?? "") else {
        return nil
      }
      return Self.versionNames[major]
    }
  #endif

  /// A default empty identity value.
  public static let empty = DeviceIdentity(
    name: "",
    model: "",
    systemName: "",
    systemVersion: "",
    totalCoreCount: 0,
    activeCoreCount: 0,
    isiOSAppOnMac: false
  )

  #if os(macOS)
    private static let versionNames: [Int: String] = [
      11: "Big Sur",
      12: "Monterey",
      13: "Ventura",
      14: "Sonoma",
      15: "Sequoia",
      16: "Tahoe",
    ]
  #endif
}
