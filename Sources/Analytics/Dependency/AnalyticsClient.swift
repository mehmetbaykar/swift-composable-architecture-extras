import Foundation

public struct AnalyticsClient<Event: Sendable>: Sendable {
  public var send: @Sendable (Event) -> Void

  public init(send: @escaping @Sendable (Event) -> Void) {
    self.send = send
  }
}

extension AnalyticsClient {
  public static func merge(_ clients: Self...) -> Self {
    .init { event in
      clients.forEach { $0.send(event) }
    }
  }
}

extension AnalyticsClient {
  public static func consoleLogger(
    prefix: String = "[Analytics]"
  ) -> Self {
    .init { event in
      #if DEBUG
        print("\(prefix) \(event)")
      #endif
    }
  }

  public static func noop() -> Self {
    .init { _ in }
  }
}
