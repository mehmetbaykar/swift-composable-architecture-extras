#if !os(tvOS)
  import ComposableArchitecture

  @testable import Haptics

  @Reducer
  struct TestReducer {
    @ObservableState
    struct State: Equatable {
      var selectedIndex: Int = 0
      var count: Int = 0
      var isHapticsEnabled: Bool = true
    }

    enum Action: Equatable {
      case selectIndex(Int)
      case increment
      case setHapticsEnabled(Bool)
    }

    var body: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .selectIndex(let index):
          state.selectedIndex = index
          return .none
        case .increment:
          state.count += 1
          return .none
        case .setHapticsEnabled(let enabled):
          state.isHapticsEnabled = enabled
          return .none
        }
      }
      #if os(iOS)
        .haptics(.selection, triggerOnChangeOf: \.selectedIndex)
        .haptics(
          .impactMedium(),
          triggerOnChangeOf: \.count,
          isEnabled: \.isHapticsEnabled
        )
      #elseif os(macOS)
        .haptics(.alignment, triggerOnChangeOf: \.selectedIndex)
        .haptics(
          .generic,
          triggerOnChangeOf: \.count,
          isEnabled: \.isHapticsEnabled
        )
      #elseif os(watchOS)
        .haptics(.watchClick, triggerOnChangeOf: \.selectedIndex)
        .haptics(
          .watchSuccess,
          triggerOnChangeOf: \.count,
          isEnabled: \.isHapticsEnabled
        )
      #endif
    }
  }
#endif
