import ComposableArchitecture
import Foundation

extension _ReducerPrinter {
  public static func prettyConsole(
    allowedActions: ActionFilter<Action> = .all,
    maxDepth: Int = 10,
    showTimestamp: Bool = false,
    debounceInterval: TimeInterval? = nil
  ) -> Self {
    _prettyConsole(
      allowedActions: allowedActions,
      maxDepth: maxDepth,
      showTimestamp: showTimestamp,
      debounceInterval: debounceInterval,
      output: { print($0) }
    )
  }

  internal static func _prettyConsole(
    allowedActions: ActionFilter<Action> = .all,
    maxDepth: Int = 10,
    showTimestamp: Bool = false,
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
      CustomDump.customDump(receivedAction, to: &actionOutput, indent: 2, maxDepth: maxDepth)

      let stateOutput =
        CustomDump.diff(oldState, newState, format: .proportional)
        ?? "  [√] NO STATE CHANGES"

      let actionLines = actionOutput.split(separator: "\n", omittingEmptySubsequences: false)
      let stateLines = stateOutput.split(separator: "\n", omittingEmptySubsequences: false)

      let maxActionWidth = actionLines.map { $0.count }.max() ?? 0
      let maxStateWidth = stateLines.map { $0.count }.max() ?? 0

      let headerText: String
      if showTimestamp {
        headerText = "[DEBUG OUTPUT] \(ISO8601DateFormatter.printerShared.string(from: Date()))"
      } else {
        headerText = "[DEBUG OUTPUT]"
      }
      let headerWidth = headerText.count

      let totalWidth = max(maxActionWidth, maxStateWidth, headerWidth)

      var result = ""
      result.write("\n")
      result.write("┌\(String(repeating: "─", count: totalWidth))┐\n")
      result.write("│\(headerText.padding(toLength: totalWidth, withPad: " ", startingAt: 0))│\n")
      result.write("├\(String(repeating: "─", count: totalWidth))┤\n")

      let actionHeader = "│ [>] ACTION:".padding(
        toLength: totalWidth + 1, withPad: " ", startingAt: 0)
      result.write("\(actionHeader)│\n")
      for line in actionLines {
        let paddedLine = "│\(line)".padding(toLength: totalWidth + 1, withPad: " ", startingAt: 0)
        result.write("\(paddedLine)│\n")
      }

      result.write("├\(String(repeating: "─", count: totalWidth))┤\n")
      let stateHeader = "│ [S] STATE:".padding(
        toLength: totalWidth + 1, withPad: " ", startingAt: 0)
      result.write("\(stateHeader)│\n")
      for line in stateLines {
        let formattedLine = "│\(line)"
        let paddedLine = formattedLine.padding(
          toLength: totalWidth + 1, withPad: " ", startingAt: 0)
        result.write("\(paddedLine)│\n")
      }
      result.write("└\(String(repeating: "─", count: totalWidth))┘\n")

      output(result)
    }
  }
}
