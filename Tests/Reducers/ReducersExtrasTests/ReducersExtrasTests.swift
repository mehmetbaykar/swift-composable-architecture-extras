import Testing

@testable import ReducersExtras

@Suite("ReducersExtras")
struct ReducersExtrasTests {

  @Test func `umbrella re-exports all reducer modules`() {
    // Verify public types from each module are accessible through the umbrella
    _ = Analytics.AnyAnalyticsClient.self
    _ = FormValidation.ValidatableField<String>.self
    _ = Haptics.HapticFeedback.self
    _ = ScreenAwake.DeviceScreenAwake.self
    _ = ScreenBrightness.BrightnessLevel.self
    _ = ScreenBrightness.ScreenBrightnessClient.self

    #if os(iOS)
      _ = AppStoreOverlay.AppStoreOverlayReducer.self
    #endif
  }
}
