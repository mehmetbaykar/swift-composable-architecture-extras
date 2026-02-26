# AudioPlayer

Cross-platform fire-and-forget audio playback dependency for TCA applications.

## Overview

`AudioPlayerClient` provides a simple, testable interface for playing audio files across all Apple platforms (iOS, macOS, tvOS, watchOS). Designed for short UI sounds and game feedback.

## Usage

```swift
@Dependency(\.audioPlayer) var audioPlayer

Button("Play Sound") {
  try? await audioPlayer.play(URL(string: "sound.mp3")!)
}
```

## Error Handling

```swift
enum AudioPlayerError: Error, Equatable {
  case fileNotFound
  case decodeFailed
  case sessionInterrupted
}
```

## Platform Notes

- **iOS/tvOS/watchOS**: Auto-configures `AVAudioSession` with `.ambient` category on first play
- **macOS**: Uses `AVAudioPlayer` directly (no session configuration needed)
- All platforms: Exclusive playback - calling `play()` stops any currently playing audio
