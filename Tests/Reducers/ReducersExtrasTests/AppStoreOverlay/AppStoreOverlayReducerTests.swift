#if os(iOS)
  import ComposableArchitecture
  import StoreKit
  import Testing

  @testable import AppStoreOverlay

  @Suite("AppStoreOverlayReducer")
  @MainActor
  struct AppStoreOverlayReducerTests {

    @Suite("Presentation")
    @MainActor
    struct PresentationTests {

      @Test func `setting overlay to non-nil presents with expected values`() async {
        let store = TestStore(
          initialState: AppStoreOverlayTestFeature.State(),
          reducer: AppStoreOverlayTestFeature.init
        )

        await store.send(.showOverlay) {
          $0.overlay = AppStoreOverlayReducer.State(appIdentifier: "1511409657")
        }
      }

      @Test func `setting overlay to nil dismisses`() async {
        let store = TestStore(
          initialState: AppStoreOverlayTestFeature.State(
            overlay: AppStoreOverlayReducer.State(appIdentifier: "1511409657")
          ),
          reducer: AppStoreOverlayTestFeature.init
        )

        await store.send(.hideOverlay) {
          $0.overlay = nil
        }
      }

      @Test func `default position is bottom`() {
        let state = AppStoreOverlayReducer.State(appIdentifier: "1511409657")
        #expect(state.position == .bottom)
      }

      @Test func `custom position is preserved`() {
        let state = AppStoreOverlayReducer.State(
          appIdentifier: "1511409657",
          position: .bottomRaised
        )
        #expect(state.position == .bottomRaised)
      }

      @Test func `dismiss via presentation action nils state`() async {
        let store = TestStore(
          initialState: AppStoreOverlayTestFeature.State(
            overlay: AppStoreOverlayReducer.State(appIdentifier: "1511409657")
          ),
          reducer: AppStoreOverlayTestFeature.init
        )

        await store.send(.overlay(.dismiss)) {
          $0.overlay = nil
        }
      }
    }
  }
#endif
