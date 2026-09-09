public struct ProcessMetrics: Sendable, Equatable {
  public let processID: Int32
  public let cpuUsage: Percentage

  public init(processID: Int32, cpuUsage: Percentage) {
    self.processID = processID
    self.cpuUsage = cpuUsage
  }

  public static let zero = ProcessMetrics(processID: 0, cpuUsage: .zero)
}
