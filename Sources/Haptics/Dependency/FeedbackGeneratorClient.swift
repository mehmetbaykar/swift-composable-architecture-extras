import Dependencies
import DependenciesMacros
import Foundation
import XCTestDynamicOverlay

@DependencyClient
public struct FeedbackGeneratorClient: Sendable {
  public var prepare: @MainActor @Sendable (HapticFeedback) async -> Void
  public var generate: @MainActor @Sendable (HapticFeedback) async -> Void
}

#if os(iOS)
  import UIKit

  @MainActor private class GeneratorHolder {
    static let shared = GeneratorHolder()
    let impactLight = UIImpactFeedbackGenerator(style: .light)
    let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
    let impactSoft = UIImpactFeedbackGenerator(style: .soft)
    let selectionGenerator = UISelectionFeedbackGenerator()
    let notificationGenerator = UINotificationFeedbackGenerator()
  }

  extension FeedbackGeneratorClient {
    public static var live: Self {

      return .init(
        prepare: { feedback in
          let generatorHolder = GeneratorHolder.shared
          switch feedback {
          case .impactLight:
            generatorHolder.impactLight.prepare()
          case .impactMedium:
            generatorHolder.impactMedium.prepare()
          case .impactHeavy:
            generatorHolder.impactHeavy.prepare()
          case .impactRigid:
            generatorHolder.impactRigid.prepare()
          case .impactSoft:
            generatorHolder.impactSoft.prepare()
          case .selection:
            generatorHolder.selectionGenerator.prepare()
          case .success, .warning, .error:
            generatorHolder.notificationGenerator.prepare()
          }
        },
        generate: { feedback in
          let generatorHolder = GeneratorHolder.shared
          switch feedback {
          case .impactLight(let intensity):
            generatorHolder.impactLight.impactOccurred(intensity: intensity)
          case .impactMedium(let intensity):
            generatorHolder.impactMedium.impactOccurred(intensity: intensity)
          case .impactHeavy(let intensity):
            generatorHolder.impactHeavy.impactOccurred(intensity: intensity)
          case .impactRigid(let intensity):
            generatorHolder.impactRigid.impactOccurred(intensity: intensity)
          case .impactSoft(let intensity):
            generatorHolder.impactSoft.impactOccurred(intensity: intensity)
          case .selection:
            generatorHolder.selectionGenerator.selectionChanged()
          case .success:
            generatorHolder.notificationGenerator.notificationOccurred(.success)
          case .warning:
            generatorHolder.notificationGenerator.notificationOccurred(.warning)
          case .error:
            generatorHolder.notificationGenerator.notificationOccurred(.error)
          }
        }
      )
    }
  }
#endif

#if os(macOS)
  import AppKit

  extension FeedbackGeneratorClient {
    public static var live: Self {
      Self(
        prepare: { _ in },
        generate: { feedback in
          let performer = NSHapticFeedbackManager.defaultPerformer
          switch feedback {
          case .alignment:
            performer.perform(.alignment, performanceTime: .default)
          case .levelChange:
            performer.perform(.levelChange, performanceTime: .default)
          case .generic:
            performer.perform(.generic, performanceTime: .default)
          }
        }
      )
    }
  }
#endif

#if os(watchOS)
  import WatchKit

  extension FeedbackGeneratorClient {
    public static var live: Self {
      Self(
        prepare: { _ in },
        generate: { feedback in
          let device = WKInterfaceDevice.current()
          switch feedback {
          case .watchNotification:
            device.play(.notification)
          case .watchDirectionUp:
            device.play(.directionUp)
          case .watchDirectionDown:
            device.play(.directionDown)
          case .watchSuccess:
            device.play(.success)
          case .watchFailure:
            device.play(.failure)
          case .watchRetry:
            device.play(.retry)
          case .watchStart:
            device.play(.start)
          case .watchStop:
            device.play(.stop)
          case .watchClick:
            device.play(.click)
          }
        }
      )
    }
  }
#endif

#if os(tvOS)
  extension FeedbackGeneratorClient {
    public static var live: Self {
      .noop()
    }
  }
#endif

extension FeedbackGeneratorClient {
  public static func consoleLogger(prefix: String = "[Haptics]") -> Self {
    Self(
      prepare: { feedback in
        #if DEBUG
          print("\(prefix) prepare: \(feedback)")
        #endif
      },
      generate: { feedback in
        #if DEBUG
          print("\(prefix) generate: \(feedback)")
        #endif
      }
    )
  }

  public static func noop() -> Self {
    Self(
      prepare: { _ in },
      generate: { _ in }
    )
  }
}

extension FeedbackGeneratorClient: TestDependencyKey {
  public static var testValue: Self {
    Self(
      prepare: { _ in
        XCTFail("Unimplemented: FeedbackGeneratorClient.prepare")
      },
      generate: { _ in
        XCTFail("Unimplemented: FeedbackGeneratorClient.generate")
      }
    )
  }

  public static var previewValue: Self {
    .consoleLogger()
  }
}

extension DependencyValues {
  public var feedbackGenerator: FeedbackGeneratorClient {
    get { self[FeedbackGeneratorClient.self] }
    set { self[FeedbackGeneratorClient.self] = newValue }
  }
}
