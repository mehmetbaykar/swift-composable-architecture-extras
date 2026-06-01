import Testing

@testable import ComposableArchitectureExtras

@Suite("ComposableArchitectureExtras")
struct ComposableArchitectureExtrasTests {

  #if Dependencies
    @Test func `umbrella re-exports dependency modules when Dependencies trait is enabled`() {
      let client = AppInfo.AppInfoClient.noop
      _ = client.appVersion()
    }
  #endif

  #if Reducers
    @Test func `umbrella re-exports reducer modules when Reducers trait is enabled`() {
      _ = Analytics.AnyAnalyticsClient.self
      _ = Haptics.HapticFeedback.self
    }
  #endif
}
