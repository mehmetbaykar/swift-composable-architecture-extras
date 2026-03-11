import Dependencies
import Foundation
import Testing
import os

@testable import LoggerClient

@MainActor
private final class LogRecorder: Sendable {
  nonisolated(unsafe) var entries: [LogEntry] = []

  var client: AppLoggerClient {
    .init { [self] entry in
      entries.append(entry)
    }
  }
}

@Suite("LoggerClient")
@MainActor
struct LoggerClientTests {

  @Suite("Merge")
  @MainActor
  struct MergeTests {

    @Test func `merge calls all clients`() {
      let recorder1 = LogRecorder()
      let recorder2 = LogRecorder()
      let merged = AppLoggerClient.merge(recorder1.client, recorder2.client)

      let entry = LogEntry(
        message: "test", level: .info, timestamp: Date(),
        file: "Test.swift", function: "test()", line: 1
      )
      merged.log(entry)

      #expect(recorder1.entries.count == 1)
      #expect(recorder2.entries.count == 1)
      #expect(recorder1.entries.first?.message == "test")
      #expect(recorder2.entries.first?.message == "test")
    }
  }

  @Suite("PlainTextFormatter")
  @MainActor
  struct PlainTextFormatterTests {

    @Test func `plain text formatter output`() {
      let formatter = PlainTextFormatter()
      let date = Date(timeIntervalSince1970: 0)
      let entry = LogEntry(
        message: "hello world", level: .info, timestamp: date,
        file: "/path/to/MyFile.swift", function: "doStuff()", line: 42
      )

      let output = formatter.format(entry)

      #expect(output.contains("INFO"))
      #expect(output.contains("MyFile.swift:42"))
      #expect(output.contains("doStuff()"))
      #expect(output.contains("hello world"))
      #expect(output.contains("|"))
    }
  }

  @Suite("ConvenienceMethods")
  @MainActor
  struct ConvenienceMethodTests {

    @Test func `convenience methods set correct level`() {
      let recorder = LogRecorder()
      let client = recorder.client

      client.debug("d")
      client.info("i")
      client.notice("n")
      client.error("e")
      client.fault("f")

      #expect(recorder.entries.count == 5)
      #expect(recorder.entries[0].level == .debug)
      #expect(recorder.entries[1].level == .info)
      #expect(recorder.entries[2].level == .default)
      #expect(recorder.entries[3].level == .error)
      #expect(recorder.entries[4].level == .fault)
    }

    @Test func `convenience methods capture source location`() {
      let recorder = LogRecorder()
      let client = recorder.client

      client.info("test")
      let entry = recorder.entries.first

      #expect(entry != nil)
      #expect(entry?.file.contains("LoggerClientTests.swift") == true)
      #expect(entry?.function.contains("convenience methods capture source location") == true)
      #expect(entry?.line != 0)
    }
  }

  @Suite("FileLogger")
  @MainActor
  struct FileLoggerTests {

    private func makeTemporaryDirectory() throws -> URL {
      let dir = FileManager.default.temporaryDirectory
        .appendingPathComponent("LoggerClientTests-\(UUID().uuidString)")
      try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
      return dir
    }

    private func cleanup(_ dir: URL) {
      try? FileManager.default.removeItem(at: dir)
    }

    @Test func `file logger writes to disk`() async throws {
      let dir = try makeTemporaryDirectory()
      defer { cleanup(dir) }

      let client = AppLoggerClient.fileLogger(
        filename: "test.log",
        directory: dir,
        maxFileSize: 5_000_000,
        maxFiles: 3
      )

      client.info("file log entry")

      try await Task.sleep(for: .milliseconds(200))

      let fileURL = dir.appendingPathComponent("test.log")
      #expect(FileManager.default.fileExists(atPath: fileURL.path))

      let contents = try String(contentsOf: fileURL, encoding: .utf8)
      #expect(contents.contains("file log entry"))
    }

    @Test func `file logger rotates at max size`() async throws {
      let dir = try makeTemporaryDirectory()
      defer { cleanup(dir) }

      let smallMaxSize: UInt64 = 100
      let client = AppLoggerClient.fileLogger(
        filename: "rotate.log",
        directory: dir,
        maxFileSize: smallMaxSize,
        maxFiles: 3
      )

      for i in 0..<20 {
        client.info("Log entry number \(i) with some padding to exceed max size threshold quickly")
      }

      try await Task.sleep(for: .milliseconds(500))

      let rotatedFile = dir.appendingPathComponent("rotate.1.log")
      #expect(FileManager.default.fileExists(atPath: rotatedFile.path))
    }
  }

  @Suite("Noop")
  @MainActor
  struct NoopTests {

    @Test func `noop discards entries`() {
      let client = AppLoggerClient.noop()
      client.info("this should be discarded")
      client.error("this too")
    }
  }

  @Suite("WithDependencies")
  @MainActor
  struct WithDependenciesTests {

    @Test func `with dependencies override`() {
      let recorder = LogRecorder()

      withDependencies {
        $0.loggerClient = recorder.client
      } operation: {
        @Dependency(\.loggerClient) var loggerClient
        loggerClient.info("injected")
      }

      #expect(recorder.entries.count == 1)
      #expect(recorder.entries.first?.message == "injected")
    }
  }
}
