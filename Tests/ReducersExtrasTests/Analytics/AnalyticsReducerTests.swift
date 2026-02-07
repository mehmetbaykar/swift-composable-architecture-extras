import ComposableArchitecture
import Testing

@testable import Analytics

@Suite("AnalyticsReducer Tests")
@MainActor
struct AnalyticsReducerTests {
  @Suite("Single event initializer")
  struct SingleEventTests {

    @Test("single event is sent when closure returns non-nil")
    @MainActor
    func singleEventSentWhenNonNil() async {
      let collector = EventCollector<SingleEventTestEvent>()

      let store = TestStore(initialState: SingleEventTestReducer.State()) {
        SingleEventTestReducer()
      } withDependencies: {
        $0.analyticsClient = AnyAnalyticsClient(
          AnalyticsClient<SingleEventTestEvent>(send: { collector.append($0) })
        )
      }

      await store.send(.increment) {
        $0.count = 1
      }

      #expect(collector.events == [.buttonTapped(id: "increment")])
    }

    @Test("no event sent when closure returns nil")
    @MainActor
    func noEventSentWhenNil() async {
      let collector = EventCollector<SingleEventTestEvent>()

      let store = TestStore(initialState: SingleEventTestReducer.State()) {
        SingleEventTestReducer()
      } withDependencies: {
        $0.analyticsClient = AnyAnalyticsClient(
          AnalyticsClient<SingleEventTestEvent>(send: { collector.append($0) })
        )
      }

      await store.send(.noAnalytics)

      #expect(collector.events.isEmpty)
    }
  }

  @Suite("Array event initializer")
  struct ArrayEventTests {

    @Test("multiple events sent from array closure")
    @MainActor
    func multipleEventsSent() async {
      let collector = EventCollector<ArrayTestEvent>()

      let store = TestStore(initialState: ArrayTestReducer.State()) {
        ArrayTestReducer()
      } withDependencies: {
        $0.analyticsClient = AnyAnalyticsClient(
          AnalyticsClient<ArrayTestEvent>(send: { collector.append($0) })
        )
      }

      await store.send(.multipleEvents)

      #expect(collector.events == [.screenViewed(name: "Test"), .buttonTapped(id: "test")])
    }

    @Test("empty array sends no events")
    @MainActor
    func emptyArraySendsNoEvents() async {
      let collector = EventCollector<ArrayTestEvent>()

      let store = TestStore(initialState: ArrayTestReducer.State()) {
        ArrayTestReducer()
      } withDependencies: {
        $0.analyticsClient = AnyAnalyticsClient(
          AnalyticsClient<ArrayTestEvent>(send: { collector.append($0) })
        )
      }

      await store.send(.emptyArray)

      #expect(collector.events.isEmpty)
    }
  }
}
