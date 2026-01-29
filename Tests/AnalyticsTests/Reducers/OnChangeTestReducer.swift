import ComposableArchitecture

@testable import Analytics

enum OnChangeTestEvent: Sendable, Equatable {
  case countChanged(old: Int, new: Int)
}

@Reducer
struct OnChangeTestReducer {
  struct State: Equatable {
    var count = 0
  }

  enum Action: Equatable {
    case increment
    case setCount(Int)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .increment:
        state.count += 1
        return .none
      case .setCount(let value):
        state.count = value
        return .none
      }
    }
    .analyticsOnChange(of: \.count) { oldValue, newValue in
      [OnChangeTestEvent.countChanged(old: oldValue, new: newValue)]
    }
  }
}

@Reducer
struct OnChangeEmptyArrayTestReducer {
  struct State: Equatable {
    var count = 0
  }

  enum Action: Equatable {
    case increment
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .increment:
        state.count += 1
        return .none
      }
    }
    .analyticsOnChange(of: \.count) { _, _ -> [OnChangeTestEvent] in
      []
    }
  }
}
