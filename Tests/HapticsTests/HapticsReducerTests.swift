import ComposableArchitecture
import Testing

@testable import Haptics

@MainActor
@Suite("HapticsReducer Tests")
struct HapticsReducerTests {

  @Suite("Haptic triggers on state change")
  struct TriggerTests {

    @Test("haptic triggers when observed value changes")
    @MainActor
    func hapticTriggersOnChange() async {
      let collector = FeedbackCollector()

      let store = TestStore(initialState: TestReducer.State()) {
        TestReducer()
      } withDependencies: {
        $0.feedbackGenerator = collector.client
      }

      await store.send(.selectIndex(1)) {
        $0.selectedIndex = 1
      }

      #if os(iOS)
        #expect(collector.feedbacks == [.selection])
      #elseif os(macOS)
        #expect(collector.feedbacks == [.alignment])
      #elseif os(watchOS)
        #expect(collector.feedbacks == [.watchClick])
      #endif
    }

    @Test("no haptic when value unchanged")
    @MainActor
    func noHapticWhenUnchanged() async {
      let collector = FeedbackCollector()

      let store = TestStore(initialState: TestReducer.State(selectedIndex: 5)) {
        TestReducer()
      } withDependencies: {
        $0.feedbackGenerator = collector.client
      }

      await store.send(.selectIndex(5))

      #expect(collector.feedbacks.isEmpty)
    }
  }

  @Suite("isEnabled controls haptic triggering")
  struct IsEnabledTests {

    @Test("haptic blocked when isEnabled returns false")
    @MainActor
    func hapticBlockedWhenDisabled() async {
      let collector = FeedbackCollector()

      let store = TestStore(initialState: TestReducer.State(isHapticsEnabled: false)) {
        TestReducer()
      } withDependencies: {
        $0.feedbackGenerator = collector.client
      }

      await store.send(.increment) {
        $0.count = 1
      }

      #expect(collector.feedbacks.isEmpty)
    }

    @Test("haptic triggers when isEnabled returns true")
    @MainActor
    func hapticTriggersWhenEnabled() async {
      let collector = FeedbackCollector()

      let store = TestStore(initialState: TestReducer.State(isHapticsEnabled: true)) {
        TestReducer()
      } withDependencies: {
        $0.feedbackGenerator = collector.client
      }

      await store.send(.increment) {
        $0.count = 1
      }

      #if os(iOS)
        #expect(collector.feedbacks == [.impactMedium()])
      #elseif os(macOS)
        #expect(collector.feedbacks == [.generic])
      #elseif os(watchOS)
        #expect(collector.feedbacks == [.watchSuccess])
      #endif
    }

    @Test("haptic behavior changes when isEnabled changes")
    @MainActor
    func hapticBehaviorChangesWithEnabledState() async {
      let collector = FeedbackCollector()

      let store = TestStore(initialState: TestReducer.State(isHapticsEnabled: true)) {
        TestReducer()
      } withDependencies: {
        $0.feedbackGenerator = collector.client
      }

      await store.send(.increment) {
        $0.count = 1
      }
      #expect(collector.feedbacks.count == 1)

      await store.send(.setHapticsEnabled(false)) {
        $0.isHapticsEnabled = false
      }

      await store.send(.increment) {
        $0.count = 2
      }

      #expect(collector.feedbacks.count == 1)
    }
  }

  @Suite("Multiple chained haptics")
  struct ChainedHapticsTests {

    @Test("multiple haptics can be chained")
    @MainActor
    func multipleChainedHaptics() async {
      let collector = FeedbackCollector()

      let store = TestStore(initialState: TestReducer.State()) {
        TestReducer()
      } withDependencies: {
        $0.feedbackGenerator = collector.client
      }

      await store.send(.selectIndex(1)) {
        $0.selectedIndex = 1
      }

      await store.send(.increment) {
        $0.count = 1
      }

      #if os(iOS)
        #expect(collector.feedbacks == [.selection, .impactMedium()])
      #elseif os(macOS)
        #expect(collector.feedbacks == [.alignment, .generic])
      #elseif os(watchOS)
        #expect(collector.feedbacks == [.watchClick, .watchSuccess])
      #endif
    }
  }
}
