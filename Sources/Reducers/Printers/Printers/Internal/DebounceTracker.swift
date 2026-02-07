import Foundation

final class DebounceTracker: @unchecked Sendable {
  private let lock = NSLock()
  private var lastPrintTime: Date?

  func shouldPrint(interval: TimeInterval) -> Bool {
    lock.lock()
    defer { lock.unlock() }

    let now = Date()
    if let lastTime = lastPrintTime,
      now.timeIntervalSince(lastTime) < interval
    {
      return false
    }
    lastPrintTime = now
    return true
  }
}
