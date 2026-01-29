import ComposableArchitecture

public struct AnalyticsReducer<State, Action, Event: Sendable>: Reducer {
  @usableFromInline
  let toAnalyticsEvents: @Sendable (State, Action) -> [Event]

  @usableFromInline
  @Dependency(\.analyticsClient) var analyticsClient

  @inlinable
  public init(
    @AnalyticsEventBuilder<Event> _ builder: @escaping @Sendable (State, Action) -> [Event]
  ) {
    self.toAnalyticsEvents = builder
  }

  @inlinable
  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    let events = toAnalyticsEvents(state, action)
    guard !events.isEmpty else { return .none }

    return .run { [analyticsClient] _ in
      for event in events {
        analyticsClient.send(event)
      }
    }
  }
}
