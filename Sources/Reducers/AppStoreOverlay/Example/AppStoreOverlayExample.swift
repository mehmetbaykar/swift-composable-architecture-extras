#if os(iOS)
  import ComposableArchitecture
  import StoreKit
  import SwiftUI

  #if DEBUG
    @Reducer
    struct AppStoreOverlayExampleFeature {
      @ObservableState
      struct State: Equatable {
        @Presents var overlay: AppStoreOverlayReducer.State?
      }

      enum Action {
        case showOverlayTapped
        case hideOverlayTapped
        case overlay(PresentationAction<AppStoreOverlayReducer.Action>)
      }

      var body: some ReducerOf<Self> {
        Reduce {
          state,
          action in
          switch action {
          case .showOverlayTapped:
            state.overlay = .init(
              appIdentifier: "1511409657",
              position: .bottomRaised
            )
            return .none
          case .hideOverlayTapped:
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

    struct AppStoreOverlayExampleView: View {
      @Perception.Bindable var store: StoreOf<AppStoreOverlayExampleFeature>

      var body: some View {
        WithPerceptionTracking {
          VStack(spacing: 20) {
            Text("App Store Overlay Example")
              .font(.headline)

            Button("Show App Store Overlay") {
              store.send(.showOverlayTapped)
            }

            Button("Hide App Store Overlay") {
              store.send(.hideOverlayTapped)
            }
          }
          .appStoreOverlay(
            $store.scope(state: \.overlay, action: \.overlay)
          )
        }
      }
    }

    #Preview {
      AppStoreOverlayExampleView(
        store: Store(
          initialState: AppStoreOverlayExampleFeature.State()
        ) {
          AppStoreOverlayExampleFeature()._printChanges()
        }
      )
    }

  #endif

#endif
