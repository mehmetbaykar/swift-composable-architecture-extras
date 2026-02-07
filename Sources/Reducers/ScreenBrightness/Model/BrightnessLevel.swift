import Foundation

public enum BrightnessLevel: Equatable, Sendable {
  case automatic
  case low
  case medium
  case high
  case max
  case custom(Double)

  var value: CGFloat? {
    switch self {
    case .automatic: return nil
    case .low: return 0.1
    case .medium: return 0.5
    case .high: return 0.9
    case .max: return 1.0
    case .custom(let value): return value
    }
  }
}
