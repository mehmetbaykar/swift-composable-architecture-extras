import Testing

@testable import Analytics

@Suite("Firebase Provider Tests")
struct FirebaseProviderTests {

  @Suite("screenView event")
  struct ScreenViewTests {
    @Test("transforms to logEvent with screen_name parameter")
    func transformsToLogEventWithScreenName() {
      let mock = MockFirebaseAnalytics()
      let client = makeFirebaseClient(mock: mock)

      client.send(.screenView(screenName: "HomeScreen", screenClass: nil))

      #expect(
        mock.calls == [
          .logEvent(
            name: "screen_view",
            parameters: [
              "screen_name": .string("HomeScreen")
            ])
        ])
    }

    @Test("includes screen_class when provided")
    func includesScreenClassWhenProvided() {
      let mock = MockFirebaseAnalytics()
      let client = makeFirebaseClient(mock: mock)

      client.send(.screenView(screenName: "ProfileScreen", screenClass: "ProfileViewController"))

      #expect(
        mock.calls == [
          .logEvent(
            name: "screen_view",
            parameters: [
              "screen_name": .string("ProfileScreen"),
              "screen_class": .string("ProfileViewController"),
            ])
        ])
    }
  }

  @Suite("login event")
  struct LoginTests {
    @Test("transforms to logEvent with method parameter")
    func transformsToLogEventWithMethod() {
      let mock = MockFirebaseAnalytics()
      let client = makeFirebaseClient(mock: mock)

      client.send(.login(method: "email"))

      #expect(
        mock.calls == [
          .logEvent(
            name: "login",
            parameters: [
              "method": .string("email")
            ])
        ])
    }
  }

  @Suite("signUp event")
  struct SignUpTests {
    @Test("transforms to logEvent with method parameter")
    func transformsToLogEventWithMethod() {
      let mock = MockFirebaseAnalytics()
      let client = makeFirebaseClient(mock: mock)

      client.send(.signUp(method: "google"))

      #expect(
        mock.calls == [
          .logEvent(
            name: "sign_up",
            parameters: [
              "method": .string("google")
            ])
        ])
    }
  }

  @Suite("purchase event")
  struct PurchaseTests {
    @Test("transforms to logEvent with value, currency, and item_id parameters")
    func transformsToLogEventWithPurchaseParams() {
      let mock = MockFirebaseAnalytics()
      let client = makeFirebaseClient(mock: mock)

      client.send(.purchase(value: 9.99, currency: "USD", itemId: "premium_subscription"))

      #expect(
        mock.calls == [
          .logEvent(
            name: "purchase",
            parameters: [
              "value": .double(9.99),
              "currency": .string("USD"),
              "item_id": .string("premium_subscription"),
            ])
        ])
    }
  }

  @Suite("selectContent event")
  struct SelectContentTests {
    @Test("transforms to logEvent with content_type and item_id parameters")
    func transformsToLogEventWithContentParams() {
      let mock = MockFirebaseAnalytics()
      let client = makeFirebaseClient(mock: mock)

      client.send(.selectContent(contentType: "article", itemId: "article_123"))

      #expect(
        mock.calls == [
          .logEvent(
            name: "select_content",
            parameters: [
              "content_type": .string("article"),
              "item_id": .string("article_123"),
            ])
        ])
    }
  }
}

private func makeFirebaseClient(mock: MockFirebaseAnalytics) -> AnalyticsClient<FirebaseTestEvent> {
  AnalyticsClient<FirebaseTestEvent> { event in
    switch event {
    case .screenView(let screenName, let screenClass):
      var params: [String: AnalyticsParam] = ["screen_name": .string(screenName)]
      if let screenClass {
        params["screen_class"] = .string(screenClass)
      }
      mock.logEvent("screen_view", parameters: params)

    case .login(let method):
      mock.logEvent("login", parameters: ["method": .string(method)])

    case .signUp(let method):
      mock.logEvent("sign_up", parameters: ["method": .string(method)])

    case .purchase(let value, let currency, let itemId):
      mock.logEvent(
        "purchase",
        parameters: [
          "value": .double(value),
          "currency": .string(currency),
          "item_id": .string(itemId),
        ])

    case .selectContent(let contentType, let itemId):
      mock.logEvent(
        "select_content",
        parameters: [
          "content_type": .string(contentType),
          "item_id": .string(itemId),
        ])
    }
  }
}
