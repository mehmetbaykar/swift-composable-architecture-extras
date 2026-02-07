import ComposableArchitecture
import Testing

@testable import ScreenAwake

@Reducer
private struct ScreenAwakeTestFeature {
  @ObservableState
  struct State: Equatable {
    var isPlaying = false
  }

  enum Action {
    case play
    case pause
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .play:
        state.isPlaying = true
        return .none
      case .pause:
        state.isPlaying = false
        return .none
      }
    }
    .screenAwake(when: \.isPlaying)
  }
}

@Suite("ScreenAwakeReducer")
@MainActor
struct ScreenAwakeReducerTests {

  @Suite("TriggerBehavior")
  @MainActor
  struct TriggerBehaviorTests {

    @Test func `trigger becomes true calls enable`() async {
      let recorder = RecordingDeviceScreenAwake()

      let store = TestStore(
        initialState: ScreenAwakeTestFeature.State(isPlaying: false),
        reducer: ScreenAwakeTestFeature.init
      ) {
        $0.deviceScreenAwake = recorder.dependency
      }

      await store.send(.play) {
        $0.isPlaying = true
      }

      #expect(recorder.calls == [.enable])
    }

    @Test func `trigger becomes false calls disable`() async {
      let recorder = RecordingDeviceScreenAwake()

      let store = TestStore(
        initialState: ScreenAwakeTestFeature.State(isPlaying: true),
        reducer: ScreenAwakeTestFeature.init
      ) {
        $0.deviceScreenAwake = recorder.dependency
      }

      await store.send(.pause) {
        $0.isPlaying = false
      }

      #expect(recorder.calls == [.disable])
    }

    @Test func `trigger unchanged from false makes no calls`() async {
      let recorder = RecordingDeviceScreenAwake()

      let store = TestStore(
        initialState: ScreenAwakeTestFeature.State(isPlaying: false),
        reducer: ScreenAwakeTestFeature.init
      ) {
        $0.deviceScreenAwake = recorder.dependency
      }

      await store.send(.pause)

      #expect(recorder.calls.isEmpty)
    }

    @Test func `trigger unchanged from true makes no calls`() async {
      let recorder = RecordingDeviceScreenAwake()

      let store = TestStore(
        initialState: ScreenAwakeTestFeature.State(isPlaying: true),
        reducer: ScreenAwakeTestFeature.init
      ) {
        $0.deviceScreenAwake = recorder.dependency
      }

      await store.send(.play)

      #expect(recorder.calls.isEmpty)
    }
  }

  @Suite("CallSequence")
  @MainActor
  struct CallSequenceTests {

    @Test func `multiple toggles produce correct call sequence`() async {
      let recorder = RecordingDeviceScreenAwake()

      let store = TestStore(
        initialState: ScreenAwakeTestFeature.State(isPlaying: false),
        reducer: ScreenAwakeTestFeature.init
      ) {
        $0.deviceScreenAwake = recorder.dependency
      }

      await store.send(.play) { $0.isPlaying = true }
      await store.send(.pause) { $0.isPlaying = false }
      await store.send(.play) { $0.isPlaying = true }

      #expect(recorder.calls == [.enable, .disable, .enable])
    }

    @Test func `rapid toggles maintain correct state`() async {
      let recorder = RecordingDeviceScreenAwake()

      let store = TestStore(
        initialState: ScreenAwakeTestFeature.State(isPlaying: false),
        reducer: ScreenAwakeTestFeature.init
      ) {
        $0.deviceScreenAwake = recorder.dependency
      }

      await store.send(.play) { $0.isPlaying = true }
      await store.send(.play)
      await store.send(.pause) { $0.isPlaying = false }
      await store.send(.pause)

      #expect(recorder.calls == [.enable, .disable])
    }
  }
}
