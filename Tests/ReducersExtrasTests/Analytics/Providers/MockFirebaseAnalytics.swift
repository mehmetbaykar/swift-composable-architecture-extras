import Foundation

final class MockFirebaseAnalytics: @unchecked Sendable {
  enum Call: Sendable, Equatable {
    case logEvent(name: String, parameters: [String: AnalyticsParam])
    case setUserID(String?)
    case setUserProperty(String?, forName: String)
  }

  private let lock = NSLock()
  private var _calls: [Call] = []

  init() {}

  var calls: [Call] {
    lock.lock()
    defer { lock.unlock() }
    return _calls
  }

  func logEvent(_ name: String, parameters: [String: AnalyticsParam]?) {
    lock.lock()
    defer { lock.unlock() }
    _calls.append(.logEvent(name: name, parameters: parameters ?? [:]))
  }

  func setUserID(_ id: String?) {
    lock.lock()
    defer { lock.unlock() }
    _calls.append(.setUserID(id))
  }

  func setUserProperty(_ value: String?, forName name: String) {
    lock.lock()
    defer { lock.unlock() }
    _calls.append(.setUserProperty(value, forName: name))
  }
}
