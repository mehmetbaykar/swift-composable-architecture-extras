import Foundation

public struct Percentage: Sendable, Equatable, CustomStringConvertible {
  public let rawValue: Double

  public init(rawValue: Double) {
    self.rawValue = rawValue
  }

  public static let zero = Percentage(rawValue: 0)

  public var value: Double {
    min(max(rawValue * 100, 0), 100)
  }

  public var formatted: String {
    String(format: "%.1f%%", value)
  }

  public var description: String { formatted }
}
