import Dependencies
import XCTestDynamicOverlay

public struct AnyAnalyticsClient: Sendable {
  @usableFromInline
  let _send: @Sendable (any Sendable) -> Void

  @inlinable
  public init<Event: Sendable>(_ client: AnalyticsClient<Event>) {
    self._send = { event in
      guard let typedEvent = event as? Event else { return }
      client.send(typedEvent)
    }
  }

  @inlinable
  public init(send: @escaping @Sendable (any Sendable) -> Void) {
    self._send = send
  }

  @inlinable
  public func send<Event: Sendable>(_ event: Event) {
    _send(event)
  }
}

extension AnyAnalyticsClient: DependencyKey {
  public static var liveValue: Self {
    .init(send: { _ in
      unimplemented(
        "AnyAnalyticsClient.send - You must provide your own analytics client implementation.")
    })
  }

  public static var testValue: Self {
    .init(send: { _ in
      unimplemented(
        "Unimplemented: \(Self.self).send")
    })
  }

  public static var previewValue: Self {
    .console
  }

  public static var console: Self {
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
