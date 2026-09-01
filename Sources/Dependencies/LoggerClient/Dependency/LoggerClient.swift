import Dependencies
import Foundation
import IssueReporting
import os

public struct AppLoggerClient: Sendable {
  public var log: @Sendable (LogEntry) -> Void

  public init(log: @escaping @Sendable (LogEntry) -> Void) {
    self.log = log
  }
}

extension AppLoggerClient {
  public func debug(
    _ message: String,
    file: String = #file,
    function: String = #function,
    line: UInt = #line
  ) {
    log(
      LogEntry(
        message: message, level: .debug, timestamp: Date(), file: file, function: function,
        line: line))
  }

  public func info(
    _ message: String,
    file: String = #file,
    function: String = #function,
    line: UInt = #line
  ) {
    log(
      LogEntry(
        message: message, level: .info, timestamp: Date(), file: file, function: function,
        line: line))
  }

  public func notice(
    _ message: String,
    file: String = #file,
    function: String = #function,
    line: UInt = #line
  ) {
    log(
      LogEntry(
        message: message, level: .default, timestamp: Date(), file: file, function: function,
        line: line))
  }

  public func error(
    _ message: String,
    file: String = #file,
    function: String = #function,
    line: UInt = #line
  ) {
    log(
      LogEntry(
        message: message, level: .error, timestamp: Date(), file: file, function: function,
        line: line))
  }

  public func fault(
    _ message: String,
    file: String = #file,
    function: String = #function,
    line: UInt = #line
  ) {
    log(
      LogEntry(
        message: message, level: .fault, timestamp: Date(), file: file, function: function,
        line: line))
  }
}

extension AppLoggerClient {
  public static func noop() -> Self {
    .init { _ in }
  }

  public static func merge(_ clients: Self...) -> Self {
    .init { entry in
      clients.forEach { $0.log(entry) }
    }
  }
}

extension AppLoggerClient: TestDependencyKey {
  public static var testValue: Self {
    .init(log: { _ in
      unimplemented("AppLoggerClient.log")
    })
  }

  public static var previewValue: Self {
    .console()
  }
}

extension DependencyValues {
  public var loggerClient: AppLoggerClient {
    get { self[AppLoggerClient.self] }
    set { self[AppLoggerClient.self] = newValue }
  }
}
