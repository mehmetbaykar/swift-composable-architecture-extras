#if os(iOS)
  import ComposableArchitecture

  @testable import AppStoreOverlay

  @Reducer
  struct AppStoreOverlayTestFeature {
    @ObservableState
    struct State: Equatable {
      @Presents var overlay: AppStoreOverlayReducer.State?
    }

    enum Action {
      case showOverlay
      case hideOverlay
      case overlay(PresentationAction<AppStoreOverlayReducer.Action>)
    }

    var body: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .showOverlay:
          state.overlay = .init(appIdentifier: "1511409657")
          return .none
        case .hideOverlay:
          state.overlay = nil
          return .none
        case .overlay:
          return .none
        }
      }
      .ifLet(\.$overlay, action: \.overlay) {
        AppStoreOverlayReducer()
      }
    }
  }
#endif
