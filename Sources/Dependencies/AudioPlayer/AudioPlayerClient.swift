import ComposableArchitecture
import Foundation

public enum AudioPlayerError: Error, Equatable, Sendable {
  case fileNotFound
  case decodeFailed
  case sessionInterrupted
}

@DependencyClient
public struct AudioPlayerClient: Sendable {
  public var play: @Sendable (_ url: URL) async throws -> Void
}

extension AudioPlayerClient: TestDependencyKey {
  public static let previewValue = Self(
    play: { _ in
      try await Task.sleep(for: 1)
    }
  )

  public static let testValue = Self()
}

extension DependencyValues {
  public var audioPlayer: AudioPlayerClient {
    get { self[AudioPlayerClient.self] }
    set { self[AudioPlayerClient.self] = newValue }
  }
}

extension Task where Success == Never, Failure == Never {
  static func sleep(for seconds: Int) async throws {
    if #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) {
      try await Task.sleep(for: .seconds(seconds))
    } else {
      try await Task.sleep(nanoseconds: UInt64(1_000_000_000) * UInt64(seconds))
    }
  }
}
