#if os(iOS)

  public enum JailbreakConfidence: Int, Sendable, Equatable, Comparable {
    case nominal = 0
    case low = 1
    case moderate = 2
    case high = 3

    public static func < (lhs: JailbreakConfidence, rhs: JailbreakConfidence) -> Bool {
      lhs.rawValue < rhs.rawValue
    }
  }

#endif
