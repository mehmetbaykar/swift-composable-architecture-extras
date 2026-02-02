import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct ScreenBrightnessClient: Sendable {
  public var set: @MainActor @Sendable (BrightnessLevel) async -> Void
}
extension ScreenBrightnessClient: TestDependencyKey {
  public static var previewValue: ScreenBrightnessClient {
    .noop
  }

  public static var testValue: ScreenBrightnessClient {
    .noop
  }

  public static var noop: ScreenBrightnessClient {
    .init(set: { _ in })
  }
}

#if os(iOS)
  import UIKit

  private actor BrightnessStateKeeper {
    var originalBrightness: CGFloat?

    func captureOriginalIfNeeded(_ value: CGFloat) {
      if originalBrightness == nil {
        originalBrightness = value
      }
    }

    func consumeOriginal() -> CGFloat? {
      defer { originalBrightness = nil }
      return originalBrightness
    }
  }

  extension ScreenBrightnessClient: DependencyKey {
    public static var liveValue: ScreenBrightnessClient {
      let state = BrightnessStateKeeper()
      return ScreenBrightnessClient(
        set: { level in
          let current = UIScreen.main.brightness
          await state.captureOriginalIfNeeded(current)

          let brightnessLevel: CGFloat
          if let value = level.value {
            brightnessLevel = value
          } else if let value = await state.consumeOriginal() {
            brightnessLevel = value
          } else {
            return
          }

          guard brightnessLevel <= 1.0 else { return }

          UIScreen.main.brightness = brightnessLevel
        }
      )
    }
  }
#endif

#if os(macOS)
  extension ScreenBrightnessClient: DependencyKey {
    public static var liveValue: ScreenBrightnessClient { .noop }
  }
#endif

#if os(watchOS)
  extension ScreenBrightnessClient: DependencyKey {
    public static var liveValue: ScreenBrightnessClient { .noop }
  }
#endif

#if os(tvOS)
  extension ScreenBrightnessClient: DependencyKey {
    public static var liveValue: ScreenBrightnessClient { .noop }
  }
#endif

extension DependencyValues {
  public var screenBrightness: ScreenBrightnessClient {
    get { self[ScreenBrightnessClient.self] }
    set { self[ScreenBrightnessClient.self] = newValue }
  }
}
