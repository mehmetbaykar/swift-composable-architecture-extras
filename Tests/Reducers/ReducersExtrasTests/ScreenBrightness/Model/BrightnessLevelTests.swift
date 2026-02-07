import Testing

@testable import ScreenBrightness

@Suite("BrightnessLevel")
struct BrightnessLevelTests {

  @Suite("PresetValues")
  struct PresetValuesTests {

    @Test func `low returns 0.1`() {
      #expect(BrightnessLevel.low.value == 0.1)
    }

    @Test func `medium returns 0.5`() {
      #expect(BrightnessLevel.medium.value == 0.5)
    }

    @Test func `high returns 0.9`() {
      #expect(BrightnessLevel.high.value == 0.9)
    }

    @Test func `max returns 1.0`() {
      #expect(BrightnessLevel.max.value == 1.0)
    }

    @Test func `automatic returns nil`() {
      #expect(BrightnessLevel.automatic.value == nil)
    }
  }

  @Suite("CustomValue")
  struct CustomValueTests {

    @Test func `custom value returns correctly`() {
      #expect(BrightnessLevel.custom(0.33).value == 0.33)
    }

    @Test func `custom zero returns 0.0`() {
      #expect(BrightnessLevel.custom(0.0).value == 0.0)
    }

    @Test func `custom one returns 1.0`() {
      #expect(BrightnessLevel.custom(1.0).value == 1.0)
    }
  }

  @Suite("Equatable")
  struct EquatableTests {

    @Test func `same preset values are equal`() {
      #expect(BrightnessLevel.max == BrightnessLevel.max)
      #expect(BrightnessLevel.low == BrightnessLevel.low)
      #expect(BrightnessLevel.automatic == BrightnessLevel.automatic)
    }

    @Test func `same custom values are equal`() {
      #expect(BrightnessLevel.custom(0.5) == BrightnessLevel.custom(0.5))
    }

    @Test func `different preset values are not equal`() {
      #expect(BrightnessLevel.low != BrightnessLevel.high)
    }

    @Test func `custom and preset with same numeric value are not equal`() {
      #expect(BrightnessLevel.custom(0.5) != BrightnessLevel.medium)
    }
  }
}
