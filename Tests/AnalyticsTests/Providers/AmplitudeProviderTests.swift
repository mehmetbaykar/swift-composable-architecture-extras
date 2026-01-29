import Testing

@testable import Analytics

@Suite("Amplitude Provider Tests")
struct AmplitudeProviderTests {

  @Suite("screenViewed event")
  struct ScreenViewedTests {
    @Test("transforms to track with screen_name property")
    func transformsToTrackWithScreenName() {
      let mock = MockAmplitudeClient()
      let client = makeAmplitudeClient(mock: mock)

      client.send(.screenViewed(screenName: "Dashboard"))

      #expect(
        mock.calls == [
          .track(
            eventType: "Screen Viewed",
            eventProperties: [
              "screen_name": .string("Dashboard")
            ])
        ])
    }
  }

  @Suite("buttonClicked event")
  struct ButtonClickedTests {
    @Test("transforms to track with button_id property")
    func transformsToTrackWithButtonId() {
      let mock = MockAmplitudeClient()
      let client = makeAmplitudeClient(mock: mock)

      client.send(.buttonClicked(buttonId: "checkout_button"))

      #expect(
        mock.calls == [
          .track(
            eventType: "Button Clicked",
            eventProperties: [
              "button_id": .string("checkout_button")
            ])
        ])
    }
  }

  @Suite("signUpCompleted event")
  struct SignUpCompletedTests {
    @Test("transforms to track with method property")
    func transformsToTrackWithMethod() {
      let mock = MockAmplitudeClient()
      let client = makeAmplitudeClient(mock: mock)

      client.send(.signUpCompleted(method: "apple"))

      #expect(
        mock.calls == [
          .track(
            eventType: "Sign Up Completed",
            eventProperties: [
              "method": .string("apple")
            ])
        ])
    }
  }

  @Suite("purchaseCompleted event")
  struct PurchaseCompletedTests {
    @Test("transforms to track with revenue and product_id properties")
    func transformsToTrackWithPurchaseProps() {
      let mock = MockAmplitudeClient()
      let client = makeAmplitudeClient(mock: mock)

      client.send(.purchaseCompleted(revenue: 29.99, productId: "yearly_plan"))

      #expect(
        mock.calls == [
          .track(
            eventType: "Purchase Completed",
            eventProperties: [
              "revenue": .double(29.99),
              "product_id": .string("yearly_plan"),
            ])
        ])
    }
  }

  @Suite("featureUsed event")
  struct FeatureUsedTests {
    @Test("transforms to track with feature_name property")
    func transformsToTrackWithFeatureName() {
      let mock = MockAmplitudeClient()
      let client = makeAmplitudeClient(mock: mock)

      client.send(.featureUsed(featureName: "dark_mode"))

      #expect(
        mock.calls == [
          .track(
            eventType: "Feature Used",
            eventProperties: [
              "feature_name": .string("dark_mode")
            ])
        ])
    }
  }
}

private func makeAmplitudeClient(mock: MockAmplitudeClient) -> AnalyticsClient<AmplitudeTestEvent> {
  AnalyticsClient<AmplitudeTestEvent> { event in
    switch event {
    case .screenViewed(let screenName):
      mock.track(
        eventType: "Screen Viewed",
        eventProperties: [
          "screen_name": .string(screenName)
        ])

    case .buttonClicked(let buttonId):
      mock.track(
        eventType: "Button Clicked",
        eventProperties: [
          "button_id": .string(buttonId)
        ])

    case .signUpCompleted(let method):
      mock.track(
        eventType: "Sign Up Completed",
        eventProperties: [
          "method": .string(method)
        ])

    case .purchaseCompleted(let revenue, let productId):
      mock.track(
        eventType: "Purchase Completed",
        eventProperties: [
          "revenue": .double(revenue),
          "product_id": .string(productId),
        ])

    case .featureUsed(let featureName):
      mock.track(
        eventType: "Feature Used",
        eventProperties: [
          "feature_name": .string(featureName)
        ])
    }
  }
}
