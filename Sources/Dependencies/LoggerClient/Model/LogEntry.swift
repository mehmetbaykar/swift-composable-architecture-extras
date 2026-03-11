import Foundation
import os

public struct LogEntry: Sendable {
  public let message: String
  public let level: OSLogType
  public let timestamp: Date
  public let file: String
  public let function: String
  public let line: UInt

  public init(
    message: String,
    level: OSLogType,
    timestamp: Date,
    file: String,
    function: String,
    line: UInt
  ) {
    self.message = message
    self.level = level
    self.timestamp = timestamp
    self.file = file
    self.function = function
    self.line = line
  }
}
