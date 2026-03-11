import Foundation
import os

public protocol LogFormatter: Sendable {
  func format(_ entry: LogEntry) -> String
}

public struct PlainTextFormatter: LogFormatter, Sendable {
  public init() {}

  public func format(_ entry: LogEntry) -> String {
    let timestamp = Self.formatDate(entry.timestamp)
    let level = Self.levelString(entry.level)
    let filename = (entry.file as NSString).lastPathComponent
    return
      "\(timestamp) | \(level) | \(filename):\(entry.line) | \(entry.function) | \(entry.message)"
  }

  static func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter.string(from: date)
  }

  static func levelString(_ level: OSLogType) -> String {
    switch level {
    case .debug: return "DEBUG"
    case .info: return "INFO "
    case .default: return "NOTE "
    case .error: return "ERROR"
    case .fault: return "FAULT"
    default: return "UNKN "
    }
  }
}
