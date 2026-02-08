import Foundation

public struct ByteCount: Sendable, Equatable, CustomStringConvertible {
  public let bytes: Int64

  public init(bytes: Int64) {
    self.bytes = bytes
  }

  public static let zero = ByteCount(bytes: 0)

  public var formatted: String {
    let formatter = ByteCountFormatter()
    formatter.countStyle = .file
    return formatter.string(fromByteCount: bytes)
  }

  public var description: String { formatted }
}
