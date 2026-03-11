import Foundation
import os

extension AppLoggerClient {
  public static func console(
    formatter: LogFormatter = PlainTextFormatter()
  ) -> Self {
    let subsystem = Bundle.main.bundleIdentifier ?? "app"
    let logger = os.Logger(subsystem: subsystem, category: "App")

    return .init { entry in
      let formatted = formatter.format(entry)
      switch entry.level {
      case .debug:
        logger.debug("\(formatted, privacy: .public)")
      case .info:
        logger.info("\(formatted, privacy: .public)")
      case .error:
        logger.error("\(formatted, privacy: .public)")
      case .fault:
        logger.fault("\(formatted, privacy: .public)")
      default:
        logger.log("\(formatted, privacy: .public)")
      }
    }
  }
}
