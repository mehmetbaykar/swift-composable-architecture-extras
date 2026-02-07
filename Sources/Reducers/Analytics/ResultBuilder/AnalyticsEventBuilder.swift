@resultBuilder
public struct AnalyticsEventBuilder<Event: Sendable> {
  @inlinable
  public static func buildBlock() -> [Event] { [] }

  @inlinable
  public static func buildExpression(_ event: Event) -> [Event] { [event] }

  @_disfavoredOverload
  @inlinable
  public static func buildExpression(_ events: [Event]) -> [Event] { events }

  @inlinable
  public static func buildBlock(_ components: [Event]...) -> [Event] {
    components.flatMap { $0 }
  }

  @inlinable
  public static func buildOptional(_ component: [Event]?) -> [Event] {
    component ?? []
  }

  @inlinable
  public static func buildEither(first component: [Event]) -> [Event] { component }

  @inlinable
  public static func buildEither(second component: [Event]) -> [Event] { component }

  @inlinable
  public static func buildArray(_ components: [[Event]]) -> [Event] {
    components.flatMap { $0 }
  }

  @inlinable
  public static func buildLimitedAvailability(_ component: [Event]) -> [Event] {
    component
  }
}
