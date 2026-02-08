public struct DeviceIdentity: Sendable, Equatable {
  public let name: String
  public let model: String
  public let systemName: String
  public let systemVersion: String

  public init(
    name: String,
    model: String,
    systemName: String,
    systemVersion: String
  ) {
    self.name = name
    self.model = model
    self.systemName = systemName
    self.systemVersion = systemVersion
  }

  public static let empty = DeviceIdentity(
    name: "",
    model: "",
    systemName: "",
    systemVersion: ""
  )
}
