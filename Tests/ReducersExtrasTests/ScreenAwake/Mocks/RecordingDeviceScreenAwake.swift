import Foundation

@testable import ScreenAwake

@MainActor
public final class RecordingDeviceScreenAwake: Sendable {
  public enum Call: Equatable, Sendable {
    case enable
    case disable
  }

  public nonisolated(unsafe) var calls: [Call] = []

  public init() {}

  public var dependency: DeviceScreenAwake {
    DeviceScreenAwake(
      enable: {
        self.calls.append(.enable)
      },
      disable: {
        self.calls.append(.disable)
      }
    )
  }

  public func reset() {
    calls.removeAll()
  }
}
