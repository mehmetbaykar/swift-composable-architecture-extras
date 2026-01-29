import Dependencies
import XCTestDynamicOverlay

public struct AnyAnalyticsClient: Sendable {
  private let _send: @Sendable (any Sendable) -> Void

  public init<Event: Sendable>(_ client: AnalyticsClient<Event>) {
    self._send = { event in
      guard let typedEvent = event as? Event else { return }
      client.send(typedEvent)
    }
  }

  private init(send: @escaping @Sendable (any Sendable) -> Void) {
    self._send = send
  }

  public func send<Event: Sendable>(_ event: Event) {
    _send(event)
  }
}

extension AnyAnalyticsClient: TestDependencyKey {
  public static var testValue: Self {
    .init(send: { _ in
      XCTestDynamicOverlay.XCTFail("Unimplemented: \(Self.self).send")
    })
  }

  public static var previewValue: Self {
    .init(send: { event in
      #if DEBUG
        print("[Analytics] \(event)")
      #endif
    })
  }
}

extension DependencyValues {
  public var analyticsClient: AnyAnalyticsClient {
    get { self[AnyAnalyticsClient.self] }
    set { self[AnyAnalyticsClient.self] = newValue }
  }
}
