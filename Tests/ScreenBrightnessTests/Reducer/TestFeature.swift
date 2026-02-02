import ComposableArchitecture

@testable import ScreenBrightness

@Reducer
struct TestFeature {
  @ObservableState
  struct State: Equatable {
    var brightnessLevel: BrightnessLevel = .automatic
  }

  enum Action {
    case setBrightness(BrightnessLevel)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .setBrightness(let level):
        state.brightnessLevel = level
        return .none
      }
    }
    .screenBrightness(level: \.brightnessLevel)
  }
}
