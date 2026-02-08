public struct DiskInfo: Sendable, Equatable {
  public let usage: Percentage
  public let total: ByteCount
  public let used: ByteCount
  public let available: ByteCount

  public init(
    usage: Percentage,
    total: ByteCount,
    used: ByteCount,
    available: ByteCount
  ) {
    self.usage = usage
    self.total = total
    self.used = used
    self.available = available
  }

  public static let zero = DiskInfo(
    usage: .zero,
    total: .zero,
    used: .zero,
    available: .zero
  )
}
