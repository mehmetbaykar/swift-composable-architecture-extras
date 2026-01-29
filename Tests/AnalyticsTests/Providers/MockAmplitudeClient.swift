import Foundation

final class MockAmplitudeClient: @unchecked Sendable {
  enum Call: Sendable, Equatable {
    case track(eventType: String, eventProperties: [String: AnalyticsParam])
    case identify(userId: String?, userProperties: [String: AnalyticsParam])
    case setUserId(String?)
  }

  private let lock = NSLock()
  private var _calls: [Call] = []

  init() {}

  var calls: [Call] {
    lock.lock()
    defer { lock.unlock() }
    return _calls
  }

  func track(eventType: String, eventProperties: [String: AnalyticsParam]?) {
    lock.lock()
    defer { lock.unlock() }
    _calls.append(.track(eventType: eventType, eventProperties: eventProperties ?? [:]))
  }

  func identify(userId: String?, userProperties: [String: AnalyticsParam]?) {
    lock.lock()
    defer { lock.unlock() }
    _calls.append(.identify(userId: userId, userProperties: userProperties ?? [:]))
  }

  func setUserId(_ id: String?) {
    lock.lock()
    defer { lock.unlock() }
    _calls.append(.setUserId(id))
  }
}
