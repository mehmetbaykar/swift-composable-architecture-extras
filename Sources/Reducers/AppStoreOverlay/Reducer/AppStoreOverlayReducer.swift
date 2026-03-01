#if os(iOS)
  import ComposableArchitecture
  import StoreKit

  extension SKOverlay.Position: @retroactive Equatable {}

  @Reducer
  public struct AppStoreOverlayReducer {
    @ObservableState
    public struct State: Equatable {
      public var appIdentifier: String
      public var position: SKOverlay.Position

      public init(
        appIdentifier: String,
        position: SKOverlay.Position = .bottom
      ) {
        self.appIdentifier = appIdentifier
        self.position = position
      }
    }

    public enum Action {}

    public init() {}

    public var body: some ReducerOf<Self> {
      EmptyReducer()
    }
  }
#endif
