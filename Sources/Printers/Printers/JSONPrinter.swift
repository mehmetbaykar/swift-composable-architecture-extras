import ComposableArchitecture
import Foundation

extension _ReducerPrinter {
  private struct JSONLogEntry: Encodable {
    let timestamp: String
    let action: String
    let diff: String?
  }

  public static func json(
    allowedActions: ActionFilter<Action> = .all,
    maxDepth: Int = 10,
    debounceInterval: TimeInterval? = nil
  ) -> Self {
    _json(
      allowedActions: allowedActions,
      maxDepth: maxDepth,
      debounceInterval: debounceInterval,
      output: { print($0) }
    )
  }

  internal static func _json(
    allowedActions: ActionFilter<Action> = .all,
    maxDepth: Int = 10,
    debounceInterval: TimeInterval? = nil,
    output: @escaping @Sendable (String) -> Void
  ) -> Self {
    let debouncer = DebounceTracker()

    return Self { receivedAction, oldState, newState in
      guard allowedActions(receivedAction) else {
        return
      }

      if let interval = debounceInterval {
        guard debouncer.shouldPrint(interval: interval) else {
          return
        }
      }

      var actionOutput = ""
      CustomDump.customDump(receivedAction, to: &actionOutput, maxDepth: maxDepth)
      let actionString = actionOutput.trimmingCharacters(in: .whitespacesAndNewlines)

      let diffString: String
      if let diff = CustomDump.diff(oldState, newState, format: .proportional) {
        diffString = diff.trimmingCharacters(in: .whitespacesAndNewlines)
      } else {
        diffString = ""
      }

      let timestamp = ISO8601DateFormatter.printerShared.string(from: Date())

      let jsonOutput = JSONLogEntry(
        timestamp: timestamp,
        action: actionString,
        diff: diffString.isEmpty ? nil : diffString
      )

      do {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(jsonOutput)
        if let jsonString = String(data: data, encoding: .utf8) {
          output(jsonString)
        }
      } catch {
        output("{\"error\":\"Failed to encode log entry\"}")
      }
    }
  }
}
