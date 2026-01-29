import ComposableArchitecture
import Testing

@testable import Analytics

@Suite("OnChangeAnalyticsReducer Tests")
@MainActor
struct OnChangeAnalyticsReducerTests {

  @Test("events sent when value changes")
  @MainActor
  func eventsSentWhenValueChanges() async {
    let collector = EventCollector<OnChangeTestEvent>()

    let store = TestStore(initialState: OnChangeTestReducer.State()) {
      OnChangeTestReducer()
    } withDependencies: {
      $0.analyticsClient = AnyAnalyticsClient(
        AnalyticsClient<OnChangeTestEvent>(send: { collector.append($0) })
      )
    }

    await store.send(.increment) {
      $0.count = 1
    }

    #expect(collector.events == [.countChanged(old: 0, new: 1)])
  }

  @Test("no events when value unchanged")
  @MainActor
  func noEventsWhenValueUnchanged() async {
    let collector = EventCollector<OnChangeTestEvent>()

    let store = TestStore(initialState: OnChangeTestReducer.State(count: 5)) {
      OnChangeTestReducer()
    } withDependencies: {
      $0.analyticsClient = AnyAnalyticsClient(
        AnalyticsClient<OnChangeTestEvent>(send: { collector.append($0) })
      )
    }

    await store.send(.setCount(5))

    #expect(collector.events.isEmpty)
  }

  @Test("empty array sends no events on change")
  @MainActor
  func emptyArraySendsNoEventsOnChange() async {
    let collector = EventCollector<OnChangeTestEvent>()

    let store = TestStore(initialState: OnChangeEmptyArrayTestReducer.State()) {
      OnChangeEmptyArrayTestReducer()
    } withDependencies: {
      $0.analyticsClient = AnyAnalyticsClient(
        AnalyticsClient<OnChangeTestEvent>(send: { collector.append($0) })
      )
    }

    await store.send(.increment) {
      $0.count = 1
    }

    #expect(collector.events.isEmpty)
  }
}
