import Dependencies
import XCTestDynamicOverlay

@usableFromInline
struct AnyAnalyticsClient: Sendable {
  @usableFromInline
  let _send: @Sendable (any Sendable) -> Void

  @usableFromInline
  init<Event: Sendable>(_ client: AnalyticsClient<Event>) {
    self._send = { event in
      guard let typedEvent = event as? Event else { return }
      client.send(typedEvent)
    }
  }

  @usableFromInline
  init(send: @escaping @Sendable (any Sendable) -> Void) {
    self._send = send
  }

  @usableFromInline
  func send<Event: Sendable>(_ event: Event) {
    _send(event)
  }
}

extension AnyAnalyticsClient: TestDependencyKey {
  @usableFromInline
  static var testValue: Self {
    .init(send: { _ in
      XCTestDynamicOverlay.XCTFail("Unimplemented: \(Self.self).send")
    })
  }

  @usableFromInline
  static var previewValue: Self {
    .init(send: { event in
      #if DEBUG
        print("[Analytics] \(event)")
      #endif
    })
  }
}

extension DependencyValues {
  var analyticsClient: AnyAnalyticsClient {
    get { self[AnyAnalyticsClient.self] }
    set { self[AnyAnalyticsClient.self] = newValue }
  }
}
