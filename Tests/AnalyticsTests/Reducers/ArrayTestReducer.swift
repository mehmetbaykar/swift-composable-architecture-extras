import ComposableArchitecture

@testable import Analytics

enum ArrayTestEvent: Sendable, Equatable {
  case screenViewed(name: String)
  case buttonTapped(id: String)
}

@Reducer
struct ArrayTestReducer {
  struct State: Equatable {
    var count = 0
  }

  enum Action: Equatable {
    case multipleEvents
    case emptyArray
  }

  var body: some ReducerOf<Self> {
    AnalyticsReducerOf<Self, ArrayTestEvent> { _, action in
      switch action {
      case .multipleEvents:
        ArrayTestEvent.screenViewed(name: "Test")
        ArrayTestEvent.buttonTapped(id: "test")
      case .emptyArray:
        []
      }
    }

    Reduce { state, action in
      .none
    }
  }
}
