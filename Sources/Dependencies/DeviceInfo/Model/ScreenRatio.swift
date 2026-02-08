#if !os(visionOS) && !os(macOS)

  public struct ScreenRatio: Sendable, Equatable {
    public let width: Double
    public let height: Double

    public init(width: Double, height: Double) {
      self.width = width
      self.height = height
    }

    public static let zero = ScreenRatio(width: 0, height: 0)
  }

#endif
