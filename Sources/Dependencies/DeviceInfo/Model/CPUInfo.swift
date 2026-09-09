public struct CPUInfo: Sendable, Equatable {
  public let usage: Percentage
  public let user: Percentage
  public let system: Percentage
  public let idle: Percentage
  public let perCoreUsage: [Percentage]

  public init(
    usage: Percentage,
    user: Percentage,
    system: Percentage,
    idle: Percentage,
    perCoreUsage: [Percentage] = []
  ) {
    self.usage = usage
    self.user = user
    self.system = system
    self.idle = idle
    self.perCoreUsage = perCoreUsage
  }

  public static let zero = CPUInfo(
    usage: .zero,
    user: .zero,
    system: .zero,
    idle: .zero,
    perCoreUsage: []
  )
}
