import ComposableArchitecture
import Foundation

public typealias AnalyticsReducerOf<R: Reducer, Event: Sendable> = AnalyticsReducer<
  R.State, R.Action, Event
>
