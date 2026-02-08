import Foundation

enum DiskMeasurement {
  static func measure() -> DiskInfo {
    let url = URL(fileURLWithPath: NSHomeDirectory())
    let keys: Set<URLResourceKey> = [
      .volumeTotalCapacityKey,
      .volumeAvailableCapacityForImportantUsageKey,
    ]

    guard let values = try? url.resourceValues(forKeys: keys),
      let totalCapacity = values.volumeTotalCapacity,
      let availableCapacity = values.volumeAvailableCapacityForImportantUsage
    else {
      return .zero
    }

    let total = Int64(totalCapacity)
    let available = Int64(availableCapacity)
    let used = max(total - available, 0)

    let usage: Double
    if total > 0 {
      usage = min(Double(used) / Double(total), 1.0)
    } else {
      usage = 0
    }

    return DiskInfo(
      usage: Percentage(rawValue: usage),
      total: ByteCount(bytes: total),
      used: ByteCount(bytes: used),
      available: ByteCount(bytes: available)
    )
  }
}
