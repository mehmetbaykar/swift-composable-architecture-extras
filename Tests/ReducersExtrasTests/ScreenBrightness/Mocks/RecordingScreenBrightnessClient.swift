import Foundation

@testable import ScreenBrightness

@MainActor
public final class RecordingScreenBrightnessClient: Sendable {
  public nonisolated(unsafe) var levels: [BrightnessLevel] = []

  public init() {}

  public var client: ScreenBrightnessClient {
    ScreenBrightnessClient(
      set: { level in
        self.levels.append(level)
      }
    )
  }

  public func reset() {
    levels.removeAll()
  }
}
