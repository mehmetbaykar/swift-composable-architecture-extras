#if os(iOS)
  import ComposableArchitecture
  import StoreKit
  import SwiftUI

  extension View {
    @preconcurrency @MainActor
    public func appStoreOverlay(
      _ item: Binding<Store<AppStoreOverlayReducer.State, AppStoreOverlayReducer.Action>?>
    ) -> some View {
      self.modifier(AppStoreOverlayModifier(item: item))
    }
  }

  private struct AppStoreOverlayModifier: ViewModifier {
    @Binding var item: Store<AppStoreOverlayReducer.State, AppStoreOverlayReducer.Action>?

    func body(content: Content) -> some View {
      WithPerceptionTracking {
        if let overlayState = item?.withState({ $0 }) {
          content.appStoreOverlay(
            isPresented: Binding<Bool>(
              get: { item != nil },
              set: { if !$0 { item = nil } }
            )
          ) {
            SKOverlay.AppConfiguration(
              appIdentifier: overlayState.appIdentifier,
              position: overlayState.position
            )
          }
        } else {
          content
        }
      }
    }
  }
#endif
