import ComposableArchitecture
import Foundation
import Testing

@testable import Printers

// MARK: - Thread-safe output capture

private final class OutputCapture: @unchecked Sendable {
  private let lock = NSLock()
  private var _outputs: [String] = []

  var outputs: [String] {
    lock.lock()
    defer { lock.unlock() }
    return _outputs
  }

  var lastOutput: String? {
    lock.lock()
    defer { lock.unlock() }
    return _outputs.last
  }

  var count: Int {
    lock.lock()
    defer { lock.unlock() }
    return _outputs.count
  }

  func append(_ output: String) {
    lock.lock()
    defer { lock.unlock() }
    _outputs.append(output)
  }

  func clear() {
    lock.lock()
    defer { lock.unlock() }
    _outputs.removeAll()
  }
}

// MARK: - Test State and Action

private struct TestState: Equatable {
  var count: Int = 0
}

private enum TestAction: Equatable {
  case increment
  case decrement
  case ignored
}

// MARK: - PrettyPrinter Tests

@Suite("PrettyPrinter Tests")
struct PrettyPrinterTests {

  @Suite("Output Format")
  struct OutputFormatTests {
    @Test func `produces box-drawing formatted output`() {
      let capture = OutputCapture()
      let printer = _ReducerPrinter<TestState, TestAction>._prettyConsole(
        output: { capture.append($0) }
      )

      printer.printChange(
        receivedAction: .increment,
        oldState: TestState(count: 0),
        newState: TestState(count: 1)
      )

      let output = capture.lastOutput ?? ""
      #expect(output.contains("┌"))
      #expect(output.contains("┐"))
      #expect(output.contains("└"))
      #expect(output.contains("┘"))
      #expect(output.contains("[DEBUG OUTPUT]"))
      #expect(output.contains("[>] ACTION:"))
      #expect(output.contains("[S] STATE:"))
    }

    @Test func `includes action name in output`() {
      let capture = OutputCapture()
      let printer = _ReducerPrinter<TestState, TestAction>._prettyConsole(
        output: { capture.append($0) }
      )

      printer.printChange(
        receivedAction: .increment,
        oldState: TestState(count: 0),
        newState: TestState(count: 1)
      )

      let output = capture.lastOutput ?? ""
      #expect(output.contains("increment"))
    }

    @Test func `shows no state changes when state unchanged`() {
      let capture = OutputCapture()
      let printer = _ReducerPrinter<TestState, TestAction>._prettyConsole(
        output: { capture.append($0) }
      )

      printer.printChange(
        receivedAction: .ignored,
        oldState: TestState(count: 0),
        newState: TestState(count: 0)
      )

      let output = capture.lastOutput ?? ""
      #expect(output.contains("NO STATE CHANGES"))
    }
  }

  @Suite("Timestamp")
  struct TimestampTests {
    @Test func `includes timestamp when enabled`() {
      let capture = OutputCapture()
      let printer = _ReducerPrinter<TestState, TestAction>._prettyConsole(
        showTimestamp: true,
        output: { capture.append($0) }
      )

      printer.printChange(
        receivedAction: .increment,
        oldState: TestState(count: 0),
        newState: TestState(count: 1)
      )

      let output = capture.lastOutput ?? ""
      // ISO 8601 format includes "T" separator and "Z" suffix
      #expect(output.contains("T"))
      #expect(output.contains("Z"))
    }

    @Test func `excludes timestamp when disabled`() {
      let capture = OutputCapture()
      let printer = _ReducerPrinter<TestState, TestAction>._prettyConsole(
        showTimestamp: false,
        output: { capture.append($0) }
      )

      printer.printChange(
        receivedAction: .increment,
        oldState: TestState(count: 0),
        newState: TestState(count: 1)
      )

      let output = capture.lastOutput ?? ""
      // Header should just be "[DEBUG OUTPUT]" without ISO 8601 timestamp
      #expect(output.contains("[DEBUG OUTPUT]"))
      // Check that header line doesn't contain a timestamp pattern
      let lines = output.split(separator: "\n")
      if let headerLine = lines.first(where: { $0.contains("[DEBUG OUTPUT]") }) {
        // If showTimestamp is false, header should not have ISO date with Z
        let headerContent = String(headerLine)
        let hasTimestamp =
          headerContent.contains("T") && headerContent.contains("Z")
          && headerContent.contains("-")
        #expect(!hasTimestamp)
      }
    }
  }

  @Suite("Action Filtering")
  struct ActionFilteringTests {
    @Test func `filters out rejected actions`() {
      let capture = OutputCapture()
      let filterOnlyIncrement = ActionFilter<TestAction> {
        if case .increment = $0 { true } else { false }
      }
      let printer = _ReducerPrinter<TestState, TestAction>._prettyConsole(
        allowedActions: filterOnlyIncrement,
        output: { capture.append($0) }
      )

      // This should be filtered out
      printer.printChange(
        receivedAction: .decrement,
        oldState: TestState(count: 1),
        newState: TestState(count: 0)
      )

      #expect(capture.count == 0)
    }

    @Test func `allows matching actions through`() {
      let capture = OutputCapture()
      let filterOnlyIncrement = ActionFilter<TestAction> {
        if case .increment = $0 { true } else { false }
      }
      let printer = _ReducerPrinter<TestState, TestAction>._prettyConsole(
        allowedActions: filterOnlyIncrement,
        output: { capture.append($0) }
      )

      printer.printChange(
        receivedAction: .increment,
        oldState: TestState(count: 0),
        newState: TestState(count: 1)
      )

      #expect(capture.count == 1)
      #expect(capture.lastOutput?.contains("increment") ?? false)
    }
  }

  @Suite("Debouncing")
  struct DebouncingTests {
    @Test func `allows first action through`() {
      let capture = OutputCapture()
      let printer = _ReducerPrinter<TestState, TestAction>._prettyConsole(
        debounceInterval: 1.0,
        output: { capture.append($0) }
      )

      printer.printChange(
        receivedAction: .increment,
        oldState: TestState(count: 0),
        newState: TestState(count: 1)
      )

      #expect(capture.count == 1)
    }

    @Test func `skips rapid successive actions`() {
      let capture = OutputCapture()
      let printer = _ReducerPrinter<TestState, TestAction>._prettyConsole(
        debounceInterval: 1.0,
        output: { capture.append($0) }
      )

      // First action should print
      printer.printChange(
        receivedAction: .increment,
        oldState: TestState(count: 0),
        newState: TestState(count: 1)
      )

      // Second action within interval should be skipped
      printer.printChange(
        receivedAction: .increment,
        oldState: TestState(count: 1),
        newState: TestState(count: 2)
      )

      #expect(capture.count == 1)
    }
  }
}

// MARK: - JSONPrinter Tests

@Suite("JSONPrinter Tests")
struct JSONPrinterTests {

  @Suite("JSON Output")
  struct JSONOutputTests {
    @Test func `produces valid JSON`() {
      let capture = OutputCapture()
      let printer = _ReducerPrinter<TestState, TestAction>._json(
        output: { capture.append($0) }
      )

      printer.printChange(
        receivedAction: .increment,
        oldState: TestState(count: 0),
        newState: TestState(count: 1)
      )

      let output = capture.lastOutput ?? ""
      // Should be parseable JSON
      let data = output.data(using: .utf8)!
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
      #expect(json != nil)
    }

    @Test func `includes timestamp field`() {
      let capture = OutputCapture()
      let printer = _ReducerPrinter<TestState, TestAction>._json(
        output: { capture.append($0) }
      )

      printer.printChange(
        receivedAction: .increment,
        oldState: TestState(count: 0),
        newState: TestState(count: 1)
      )

      let output = capture.lastOutput ?? ""
      let data = output.data(using: .utf8)!
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
      #expect(json?["timestamp"] != nil)
    }

    @Test func `includes action field`() {
      let capture = OutputCapture()
      let printer = _ReducerPrinter<TestState, TestAction>._json(
        output: { capture.append($0) }
      )

      printer.printChange(
        receivedAction: .increment,
        oldState: TestState(count: 0),
        newState: TestState(count: 1)
      )

      let output = capture.lastOutput ?? ""
      let data = output.data(using: .utf8)!
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
      let action = json?["action"] as? String
      #expect(action?.contains("increment") ?? false)
    }

    @Test func `includes diff when state changes`() {
      let capture = OutputCapture()
      let printer = _ReducerPrinter<TestState, TestAction>._json(
        output: { capture.append($0) }
      )

      printer.printChange(
        receivedAction: .increment,
        oldState: TestState(count: 0),
        newState: TestState(count: 1)
      )

      let output = capture.lastOutput ?? ""
      let data = output.data(using: .utf8)!
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
      #expect(json?["diff"] != nil)
    }

    @Test func `excludes diff when state unchanged`() {
      let capture = OutputCapture()
      let printer = _ReducerPrinter<TestState, TestAction>._json(
        output: { capture.append($0) }
      )

      printer.printChange(
        receivedAction: .increment,
        oldState: TestState(count: 0),
        newState: TestState(count: 0)
      )

      let output = capture.lastOutput ?? ""
      let data = output.data(using: .utf8)!
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
      #expect(json?["diff"] == nil)
    }
  }

  @Suite("JSON Filtering")
  struct JSONFilteringTests {
    @Test func `filters out rejected actions`() {
      let capture = OutputCapture()
      let filterNone = ActionFilter<TestAction> { _ in false }
      let printer = _ReducerPrinter<TestState, TestAction>._json(
        allowedActions: filterNone,
        output: { capture.append($0) }
      )

      printer.printChange(
        receivedAction: .increment,
        oldState: TestState(count: 0),
        newState: TestState(count: 1)
      )

      #expect(capture.count == 0)
    }
  }
}
