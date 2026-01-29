import ComposableArchitecture

@testable import Analytics

enum SingleEventTestEvent: Sendable, Equatable {
  case screenViewed(name: String)
  case buttonTapped(id: String)
}

@Reducer
struct SingleEventTestReducer {
  struct State: Equatable {
    var count = 0
  }

  enum Action: Equatable {
    case increment
    case decrement
    case noAnalytics
  }

  var body: some ReducerOf<Self> {
    AnalyticsReducerOf<Self, SingleEventTestEvent> { _, action in
      switch action {
      case .increment:
        return .buttonTapped(id: "increment")
      case .decrement:
        return .buttonTapped(id: "decrement")
      case .noAnalytics:
        return nil
      }
    }

    Reduce { state, action in
      switch action {
      case .increment:
        state.count += 1
        return .none
      case .decrement:
        state.count -= 1
        return .none
      case .noAnalytics:
        return .none
      }
    }
  }
}
