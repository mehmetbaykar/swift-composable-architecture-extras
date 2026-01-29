import Foundation

final class EventCollector<Event: Sendable>: @unchecked Sendable {
  private let lock = NSLock()
  private var _events: [Event] = []

  init() {}

  var events: [Event] {
    lock.lock()
    defer { lock.unlock() }
    return _events
  }

  func append(_ event: Event) {
    lock.lock()
    defer { lock.unlock() }
    _events.append(event)
  }
}
