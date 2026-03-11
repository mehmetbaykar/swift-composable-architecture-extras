import Foundation

actor FileLogActor {
  private let fileURL: URL
  private let directory: URL
  private let filename: String
  private let maxFileSize: UInt64
  private let maxFiles: Int
  private let formatter: LogFormatter

  init(
    filename: String,
    directory: URL,
    maxFileSize: UInt64,
    maxFiles: Int,
    formatter: LogFormatter
  ) {
    self.filename = filename
    self.directory = directory
    self.maxFileSize = maxFileSize
    self.maxFiles = maxFiles
    self.formatter = formatter
    self.fileURL = directory.appendingPathComponent(filename)
  }

  func write(_ entry: LogEntry) {
    let formatted = formatter.format(entry)
    ensureDirectoryExists()
    appendToFile(formatted + "\n")
    rotateIfNeeded()
  }

  private func appendToFile(_ string: String) {
    guard let data = string.data(using: .utf8) else { return }

    if FileManager.default.fileExists(atPath: fileURL.path) {
      guard let handle = try? FileHandle(forWritingTo: fileURL) else { return }
      defer { try? handle.close() }
      handle.seekToEndOfFile()
      handle.write(data)
    } else {
      try? data.write(to: fileURL, options: .atomic)
    }
  }

  private func rotateIfNeeded() {
    guard let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
      let fileSize = attributes[.size] as? UInt64,
      fileSize >= maxFileSize
    else { return }

    let manager = FileManager.default
    let baseName = (filename as NSString).deletingPathExtension
    let ext = (filename as NSString).pathExtension

    for index in stride(from: maxFiles - 1, through: 1, by: -1) {
      let source = directory.appendingPathComponent("\(baseName).\(index).\(ext)")
      let destination = directory.appendingPathComponent("\(baseName).\(index + 1).\(ext)")

      if index + 1 >= maxFiles {
        try? manager.removeItem(at: source)
      } else if manager.fileExists(atPath: source.path) {
        try? manager.removeItem(at: destination)
        try? manager.moveItem(at: source, to: destination)
      }
    }

    let firstRotated = directory.appendingPathComponent("\(baseName).1.\(ext)")
    try? manager.removeItem(at: firstRotated)
    try? manager.moveItem(at: fileURL, to: firstRotated)
  }

  private func ensureDirectoryExists() {
    let manager = FileManager.default
    if !manager.fileExists(atPath: directory.path) {
      try? manager.createDirectory(at: directory, withIntermediateDirectories: true)
    }
  }
}
