import ComposableArchitecture
import Testing

@testable import Filter

@Suite("FilterReducer")
@MainActor
struct FilterReducerTests {

  @Test func `action passes through when predicate returns true`() async {
    let store = TestStore(
      initialState: CounterReducer.State(),
      reducer: {
        CounterReducer()
          .filter { _, _ in true }
      }
    )

    await store.send(.increment) {
      $0.count = 1
    }
  }

  @Test func `action is blocked when predicate returns false`() async {
    let store = TestStore(
      initialState: CounterReducer.State(),
      reducer: {
        CounterReducer()
          .filter { _, _ in false }
      }
    )

    await store.send(.increment)
  }

  @Test func `filter based on state value allows conditional processing`() async {
    let store = TestStore(
      initialState: CounterReducer.State(count: 0, isEnabled: true),
      reducer: {
        CounterReducer()
          .filter { state, _ in state.isEnabled }
      }
    )

    await store.send(.increment) {
      $0.count = 1
    }

    await store.send(.setEnabled(false)) {
      $0.isEnabled = false
    }

    await store.send(.increment)
  }

  @Test func `filter based on action type selectively blocks actions`() async {
    let store = TestStore(
      initialState: CounterReducer.State(),
      reducer: {
        CounterReducer()
          .filter { _, action in
            switch action {
            case .increment:
              return true
            case .decrement:
              return false
            case .setEnabled:
              return true
            }
          }
      }
    )

    await store.send(.increment) {
      $0.count = 1
    }

    await store.send(.decrement)

    await store.send(.increment) {
      $0.count = 2
    }
  }

  @Test func `multiple actions with mixed filtering`() async {
    let store = TestStore(
      initialState: CounterReducer.State(count: 5, isEnabled: true),
      reducer: {
        CounterReducer()
          .filter { state, action in
            switch action {
            case .increment:
              return state.count < 10
            case .decrement:
              return state.count > 0
            case .setEnabled:
              return true
            }
          }
      }
    )

    await store.send(.increment) {
      $0.count = 6
    }

    await store.send(.decrement) {
      $0.count = 5
    }

    await store.send(.increment) {
      $0.count = 6
    }
    await store.send(.increment) {
      $0.count = 7
    }
    await store.send(.increment) {
      $0.count = 8
    }
    await store.send(.increment) {
      $0.count = 9
    }
    await store.send(.increment) {
      $0.count = 10
    }

    await store.send(.increment)

    await store.send(.decrement) {
      $0.count = 9
    }
  }
}
