import Foundation

extension AppLoggerClient {
  public static func fileLogger(
    filename: String = "app.log",
    directory: URL? = nil,
    maxFileSize: UInt64 = 5_000_000,
    maxFiles: Int = 3,
    formatter: LogFormatter = PlainTextFormatter()
  ) -> Self {
    let logsDirectory =
      directory
      ?? FileManager.default.urls(
        for: .cachesDirectory,
        in: .userDomainMask
      ).first!.appendingPathComponent("Logs")

    let actor = FileLogActor(
      filename: filename,
      directory: logsDirectory,
      maxFileSize: maxFileSize,
      maxFiles: maxFiles,
      formatter: formatter
    )

    return .init { entry in
      Task { await actor.write(entry) }
    }
  }
}
