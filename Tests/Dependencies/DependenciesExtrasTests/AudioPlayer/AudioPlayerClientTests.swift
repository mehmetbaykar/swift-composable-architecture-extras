import Dependencies
import Foundation
import Testing

@testable import AudioPlayer

private let testURL = URL(string: "https://example.com/sound.mp3")!

@MainActor
private final class AudioPlayerRecorder: Sendable {
  nonisolated(unsafe) var playedURLs: [URL] = []
  nonisolated(unsafe) var shouldThrow: AudioPlayerError?

  var client: AudioPlayerClient {
    AudioPlayerClient(
      play: { [self] url in
        if let error = shouldThrow {
          throw error
        }
        playedURLs.append(url)
      }
    )
  }
}

@Suite("AudioPlayerClient")
@MainActor
struct AudioPlayerClientTests {

  @Suite("CustomValues")
  @MainActor
  struct CustomValueTests {

    @Test func `custom play records URL`() async throws {
      let recorder = AudioPlayerRecorder()
      try await recorder.client.play(testURL)
      #expect(recorder.playedURLs == [testURL])
    }

    @Test func `custom play throws fileNotFound`() async {
      let recorder = AudioPlayerRecorder()
      recorder.shouldThrow = .fileNotFound

      await #expect(throws: AudioPlayerError.fileNotFound) {
        try await recorder.client.play(testURL)
      }
      #expect(recorder.playedURLs.isEmpty)
    }

    @Test func `custom play throws decodeFailed`() async {
      let recorder = AudioPlayerRecorder()
      recorder.shouldThrow = .decodeFailed

      await #expect(throws: AudioPlayerError.decodeFailed) {
        try await recorder.client.play(testURL)
      }
    }

    @Test func `custom play throws sessionInterrupted`() async {
      let recorder = AudioPlayerRecorder()
      recorder.shouldThrow = .sessionInterrupted

      await #expect(throws: AudioPlayerError.sessionInterrupted) {
        try await recorder.client.play(testURL)
      }
    }

    @Test func `multiple plays record all URLs in order`() async throws {
      let recorder = AudioPlayerRecorder()
      let url1 = URL(string: "https://example.com/a.mp3")!
      let url2 = URL(string: "https://example.com/b.mp3")!
      let url3 = URL(string: "https://example.com/c.mp3")!

      try await recorder.client.play(url1)
      try await recorder.client.play(url2)
      try await recorder.client.play(url3)

      #expect(recorder.playedURLs == [url1, url2, url3])
    }
  }

  @Suite("WithDependencies")
  @MainActor
  struct WithDependenciesTests {

    @Test func `overridden dependency records URL`() async throws {
      let recorder = AudioPlayerRecorder()

      try await withDependencies {
        $0.audioPlayer = recorder.client
      } operation: {
        @Dependency(\.audioPlayer) var audioPlayer
        try await audioPlayer.play(testURL)
      }

      #expect(recorder.playedURLs == [testURL])
    }

    @Test func `overridden dependency propagates error`() async {
      let recorder = AudioPlayerRecorder()
      recorder.shouldThrow = .fileNotFound

      await #expect(throws: AudioPlayerError.fileNotFound) {
        try await withDependencies {
          $0.audioPlayer = recorder.client
        } operation: {
          @Dependency(\.audioPlayer) var audioPlayer
          try await audioPlayer.play(testURL)
        }
      }
    }
  }

  @Suite("ErrorEquatable")
  struct ErrorEquatableTests {

    @Test func `errors are equatable`() {
      #expect(AudioPlayerError.fileNotFound == AudioPlayerError.fileNotFound)
      #expect(AudioPlayerError.decodeFailed == AudioPlayerError.decodeFailed)
      #expect(AudioPlayerError.sessionInterrupted == AudioPlayerError.sessionInterrupted)
      #expect(AudioPlayerError.fileNotFound != AudioPlayerError.decodeFailed)
    }
  }
}
