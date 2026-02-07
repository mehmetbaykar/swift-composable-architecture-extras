import Testing

@testable import Analytics

@Suite("AnalyticsClient Tests")
struct AnalyticsClientTests {
  @Suite("merge")
  struct MergeTests {

    @Test("merge combines multiple clients")
    func mergeCombinesMultipleClients() async {
      let collector1 = EventCollector<SingleEventTestEvent>()
      let collector2 = EventCollector<SingleEventTestEvent>()

      let client1 = AnalyticsClient<SingleEventTestEvent>(send: { collector1.append($0) })
      let client2 = AnalyticsClient<SingleEventTestEvent>(send: { collector2.append($0) })

      let merged = AnalyticsClient<SingleEventTestEvent>.merge(client1, client2)

      merged.send(.screenViewed(name: "Home"))
      merged.send(.buttonTapped(id: "login"))

      #expect(collector1.events == [.screenViewed(name: "Home"), .buttonTapped(id: "login")])
      #expect(collector2.events == [.screenViewed(name: "Home"), .buttonTapped(id: "login")])
    }
  }

  @Suite("noop")
  struct NoopTests {

    @Test("noop discards events without crash")
    func noopDiscardsEvents() async {
      let client = AnalyticsClient<SingleEventTestEvent>.noop()

      client.send(.screenViewed(name: "Test"))
      client.send(.buttonTapped(id: "test"))
    }
  }

  @Suite("consoleLogger")
  struct ConsoleLoggerTests {

    @Test("consoleLogger creates client without crash")
    func consoleLoggerCreatesClient() async {
      let client = AnalyticsClient<SingleEventTestEvent>.consoleLogger()

      client.send(.screenViewed(name: "Test"))
    }

    @Test("consoleLogger accepts custom prefix")
    func consoleLoggerAcceptsCustomPrefix() async {
      let client = AnalyticsClient<SingleEventTestEvent>.consoleLogger(prefix: "[Custom]")

      client.send(.buttonTapped(id: "test"))
    }
  }
}
