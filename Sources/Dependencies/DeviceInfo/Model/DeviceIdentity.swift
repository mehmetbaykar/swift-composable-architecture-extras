public struct DeviceIdentity: Sendable, Equatable {
  public let name: String
  public let model: String
  public let systemName: String
  public let systemVersion: String
  public let totalCoreCount: Int
  public let activeCoreCount: Int
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

  public static let empty = DeviceIdentity(
    name: "",
    model: "",
    systemName: "",
    systemVersion: "",
    totalCoreCount: 0,
    activeCoreCount: 0,
    isiOSAppOnMac: false
  )
}
