public struct MemoryInfo: Sendable, Equatable {
  public let usage: Percentage
  public let total: ByteCount
  public let used: ByteCount
  public let available: ByteCount
  public let active: ByteCount
  public let inactive: ByteCount
  public let wired: ByteCount
  public let purgeable: ByteCount

  public init(
    usage: Percentage,
    total: ByteCount,
    used: ByteCount,
    available: ByteCount,
    active: ByteCount = .zero,
    inactive: ByteCount = .zero,
    wired: ByteCount = .zero,
    purgeable: ByteCount = .zero
  ) {
    self.usage = usage
    self.total = total
    self.used = used
    self.available = available
    self.active = active
    self.inactive = inactive
    self.wired = wired
    self.purgeable = purgeable
  }

  public static let zero = MemoryInfo(
    usage: .zero,
    total: .zero,
    used: .zero,
    available: .zero,
    active: .zero,
    inactive: .zero,
    wired: .zero,
    purgeable: .zero
  )
}
