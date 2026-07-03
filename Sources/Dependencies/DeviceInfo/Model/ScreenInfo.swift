#if !os(visionOS)
  import CoreGraphics

  public struct ScreenInfo: Sendable, Equatable {
    public let width: CGFloat
    public let height: CGFloat
    public let scale: CGFloat
    public let nativePixelWidth: Int
    public let nativePixelHeight: Int

    #if os(iOS)
      public let screenRatio: ScreenRatio
      public let diagonal: Double
      public let ppi: Int
      public let hasNotch: Bool
      public let hasDynamicIsland: Bool
      public let hasRoundedDisplayCorners: Bool

      public init(
        width: CGFloat,
        height: CGFloat,
        scale: CGFloat,
        nativePixelWidth: Int = 0,
        nativePixelHeight: Int = 0,
        screenRatio: ScreenRatio,
        diagonal: Double,
        ppi: Int,
        hasNotch: Bool,
        hasDynamicIsland: Bool,
        hasRoundedDisplayCorners: Bool
      ) {
        self.width = width
        self.height = height
        self.scale = scale
        self.nativePixelWidth = nativePixelWidth
        self.nativePixelHeight = nativePixelHeight
        self.screenRatio = screenRatio
        self.diagonal = diagonal
        self.ppi = ppi
        self.hasNotch = hasNotch
        self.hasDynamicIsland = hasDynamicIsland
        self.hasRoundedDisplayCorners = hasRoundedDisplayCorners
      }

      public static let zero = ScreenInfo(
        width: 0,
        height: 0,
        scale: 0,
        nativePixelWidth: 0,
        nativePixelHeight: 0,
        screenRatio: .zero,
        diagonal: 0,
        ppi: 0,
        hasNotch: false,
        hasDynamicIsland: false,
        hasRoundedDisplayCorners: false
      )

    #elseif os(tvOS)
      public let screenRatio: ScreenRatio

      public init(
        width: CGFloat,
        height: CGFloat,
        scale: CGFloat,
        nativePixelWidth: Int = 0,
        nativePixelHeight: Int = 0,
        screenRatio: ScreenRatio
      ) {
        self.width = width
        self.height = height
        self.scale = scale
        self.nativePixelWidth = nativePixelWidth
        self.nativePixelHeight = nativePixelHeight
        self.screenRatio = screenRatio
      }

      public static let zero = ScreenInfo(
        width: 0,
        height: 0,
        scale: 0,
        nativePixelWidth: 0,
        nativePixelHeight: 0,
        screenRatio: .zero
      )

    #elseif os(watchOS)
      public let screenRatio: ScreenRatio
      public let diagonal: Double
      public let ppi: Int

      public init(
        width: CGFloat,
        height: CGFloat,
        scale: CGFloat,
        nativePixelWidth: Int = 0,
        nativePixelHeight: Int = 0,
        screenRatio: ScreenRatio,
        diagonal: Double,
        ppi: Int
      ) {
        self.width = width
        self.height = height
        self.scale = scale
        self.nativePixelWidth = nativePixelWidth
        self.nativePixelHeight = nativePixelHeight
        self.screenRatio = screenRatio
        self.diagonal = diagonal
        self.ppi = ppi
      }

      public static let zero = ScreenInfo(
        width: 0,
        height: 0,
        scale: 0,
        nativePixelWidth: 0,
        nativePixelHeight: 0,
        screenRatio: .zero,
        diagonal: 0,
        ppi: 0
      )

    #elseif os(macOS)
      public init(
        width: CGFloat,
        height: CGFloat,
        scale: CGFloat,
        nativePixelWidth: Int = 0,
        nativePixelHeight: Int = 0
      ) {
        self.width = width
        self.height = height
        self.scale = scale
        self.nativePixelWidth = nativePixelWidth
        self.nativePixelHeight = nativePixelHeight
      }

      public static let zero = ScreenInfo(
        width: 0,
        height: 0,
        scale: 0,
        nativePixelWidth: 0,
        nativePixelHeight: 0
      )
    #endif
  }

#endif
