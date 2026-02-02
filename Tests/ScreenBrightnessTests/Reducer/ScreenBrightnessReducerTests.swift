import ComposableArchitecture
import Testing

@testable import ScreenBrightness

@Suite("ScreenBrightnessReducer")
@MainActor
struct ScreenBrightnessReducerTests {

  @Suite("TriggerBehavior")
  @MainActor
  struct TriggerBehaviorTests {

    @Test func `brightness level change triggers set call`() async {
      let recorder = RecordingScreenBrightnessClient()

      let store = TestStore(
        initialState: TestFeature.State(),
        reducer: TestFeature.init
      ) {
        $0.screenBrightness = recorder.client
      }

      await store.send(.setBrightness(.max)) {
        $0.brightnessLevel = .max
      }

      #expect(recorder.levels == [.max])
    }

    @Test func `automatic restores brightness`() async {
      let recorder = RecordingScreenBrightnessClient()

      let store = TestStore(
        initialState: TestFeature.State(brightnessLevel: .high),
        reducer: TestFeature.init
      ) {
        $0.screenBrightness = recorder.client
      }

      await store.send(.setBrightness(.automatic)) {
        $0.brightnessLevel = .automatic
      }

      #expect(recorder.levels == [.automatic])
    }

    @Test func `same value does not trigger duplicate call`() async {
      let recorder = RecordingScreenBrightnessClient()

      let store = TestStore(
        initialState: TestFeature.State(brightnessLevel: .max),
        reducer: TestFeature.init
      ) {
        $0.screenBrightness = recorder.client
      }

      await store.send(.setBrightness(.max))

      #expect(recorder.levels.isEmpty)
    }

    @Test func `custom brightness value triggers correctly`() async {
      let recorder = RecordingScreenBrightnessClient()

      let store = TestStore(
        initialState: TestFeature.State(),
        reducer: TestFeature.init
      ) {
        $0.screenBrightness = recorder.client
      }

      await store.send(.setBrightness(.custom(0.75))) {
        $0.brightnessLevel = .custom(0.75)
      }

      #expect(recorder.levels == [.custom(0.75)])
    }
  }

  @Suite("CallSequence")
  @MainActor
  struct CallSequenceTests {

    @Test func `multiple changes produce correct sequence`() async {
      let recorder = RecordingScreenBrightnessClient()

      let store = TestStore(
        initialState: TestFeature.State(),
        reducer: TestFeature.init
      ) {
        $0.screenBrightness = recorder.client
      }

      await store.send(.setBrightness(.low)) { $0.brightnessLevel = .low }
      await store.send(.setBrightness(.medium)) { $0.brightnessLevel = .medium }
      await store.send(.setBrightness(.high)) { $0.brightnessLevel = .high }
      await store.send(.setBrightness(.automatic)) { $0.brightnessLevel = .automatic }

      #expect(recorder.levels == [.low, .medium, .high, .automatic])
    }

    @Test func `rapid changes with duplicates filters correctly`() async {
      let recorder = RecordingScreenBrightnessClient()

      let store = TestStore(
        initialState: TestFeature.State(),
        reducer: TestFeature.init
      ) {
        $0.screenBrightness = recorder.client
      }

      await store.send(.setBrightness(.max)) { $0.brightnessLevel = .max }
      await store.send(.setBrightness(.max))
      await store.send(.setBrightness(.low)) { $0.brightnessLevel = .low }
      await store.send(.setBrightness(.low))

      #expect(recorder.levels == [.max, .low])
    }
  }
}
