import AVFoundation
import Dependencies

extension AudioPlayerClient: DependencyKey {
  public static let liveValue: Self = Self { url in
    try await withCheckedThrowingContinuation { continuation in
      continuation.resume(
        with: Result {
          let player = try AVAudioPlayer(contentsOf: url)
          player.prepareToPlay()

          let delegate = Delegate(
            didFinishPlaying: { successful in
              if successful {
                continuation.resume()
              } else {
                continuation.resume(throwing: AudioPlayerError.decodeFailed)
              }
            },
            decodeErrorDidOccur: { _ in
              continuation.resume(throwing: AudioPlayerError.decodeFailed)
            }
          )
          player.delegate = delegate

          PlayerStorage.shared.set(player: player, delegate: delegate)
          configureSessionOnce()

          player.play()
        })
    }
  }
}

private func configureSessionOnce() {
  #if os(iOS) || os(tvOS) || os(watchOS)
    _ = SessionConfigurator.shared
  #endif
}

#if os(iOS) || os(tvOS) || os(watchOS)
  private final class SessionConfigurator: @unchecked Sendable {
    static let shared = SessionConfigurator()

    init() {
      try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
      try? AVAudioSession.sharedInstance().setActive(true)
    }
  }
#endif

private final class Delegate: NSObject, AVAudioPlayerDelegate, @unchecked Sendable {
  let didFinishPlaying: @Sendable (Bool) -> Void
  let decodeErrorDidOccur: @Sendable (Error?) -> Void

  init(
    didFinishPlaying: @escaping @Sendable (Bool) -> Void,
    decodeErrorDidOccur: @escaping @Sendable (Error?) -> Void
  ) {
    self.didFinishPlaying = didFinishPlaying
    self.decodeErrorDidOccur = decodeErrorDidOccur
    super.init()
  }

  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    didFinishPlaying(flag)
  }

  func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
    decodeErrorDidOccur(error)
  }
}

private final class PlayerStorage: @unchecked Sendable {
  static let shared = PlayerStorage()
  private let lock = NSLock()
  private var currentPlayer: AVAudioPlayer?
  private var currentDelegate: Delegate?

  func set(player: AVAudioPlayer, delegate: Delegate) {
    lock.lock()
    defer { lock.unlock() }
    currentPlayer?.stop()
    currentPlayer = player
    currentDelegate = delegate
  }
}
