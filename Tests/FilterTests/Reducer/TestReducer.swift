import ComposableArchitecture

@testable import Filter

@Reducer
struct CounterReducer {
  @ObservableState
  struct State: Equatable {
    var count = 0
    var isEnabled = true
  }

  enum Action {
    case increment
    case decrement
    case setEnabled(Bool)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .increment:
        state.count += 1
        return .none
      case .decrement:
        state.count -= 1
        return .none
      case .setEnabled(let enabled):
        state.isEnabled = enabled
        return .none
      }
    }
  }
}
