import ComposableArchitecture

extension Reducer {
  @inlinable
  public func analyticsOnChange<Value: Equatable & Sendable, Event: Sendable>(
    of toValue: @escaping @Sendable (State) -> Value,
    _ toAnalyticsEvents: @escaping @Sendable (Value, Value) -> [Event]
  ) -> _OnChangeAnalyticsReducer<Self, Value, Event> {
    _OnChangeAnalyticsReducer(
      base: self,
      toValue: toValue,
      isDuplicate: ==,
      toAnalyticsEvents: toAnalyticsEvents
    )
  }
}

public struct _OnChangeAnalyticsReducer<
  Base: Reducer, Value: Equatable & Sendable, Event: Sendable
>:
  Reducer
{
  @usableFromInline
  let base: Base

  @usableFromInline
  let toValue: @Sendable (Base.State) -> Value

  @usableFromInline
  let isDuplicate: @Sendable (Value, Value) -> Bool

  @usableFromInline
  @Dependency(\.analyticsClient) var analyticsClient

  @usableFromInline
  let toAnalyticsEvents: @Sendable (Value, Value) -> [Event]

  @usableFromInline
  init(
    base: Base,
    toValue: @escaping @Sendable (Base.State) -> Value,
    isDuplicate: @escaping @Sendable (Value, Value) -> Bool,
    toAnalyticsEvents: @escaping @Sendable (Value, Value) -> [Event]
  ) {
    self.base = base
    self.toValue = toValue
    self.isDuplicate = isDuplicate
    self.toAnalyticsEvents = toAnalyticsEvents
  }

  @inlinable
  public func reduce(into state: inout Base.State, action: Base.Action) -> Effect<Base.Action> {
    let oldValue = toValue(state)
    let effects = base.reduce(into: &state, action: action)
    let newValue = toValue(state)

    guard !isDuplicate(oldValue, newValue) else {
      return effects
    }

    let events = toAnalyticsEvents(oldValue, newValue)
    guard !events.isEmpty else {
      return effects
    }

    return effects.merge(
      with: .run { [analyticsClient] _ in
        for event in events {
          analyticsClient.send(event)
        }
      })
  }
}
