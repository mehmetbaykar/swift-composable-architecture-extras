#if os(iOS)

  public struct JailbreakStatus: Sendable, Equatable {
    public let confidence: JailbreakConfidence

    public init(confidence: JailbreakConfidence) {
      self.confidence = confidence
    }

    public static let nominal = JailbreakStatus(confidence: .nominal)
  }

#endif
