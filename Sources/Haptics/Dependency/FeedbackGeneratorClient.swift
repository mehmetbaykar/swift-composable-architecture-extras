import Dependencies
import Foundation
import XCTestDynamicOverlay

public struct FeedbackGeneratorClient: Sendable {
  public var prepare: @Sendable (HapticFeedback) async -> Void
  public var generate: @Sendable (HapticFeedback) async -> Void

  public init(
    prepare: @escaping @Sendable (HapticFeedback) async -> Void,
    generate: @escaping @Sendable (HapticFeedback) async -> Void
  ) {
    self.prepare = prepare
    self.generate = generate
  }
}

#if os(iOS)
  import UIKit

  extension FeedbackGeneratorClient {
    public static var live: Self {
      let impactLight = UIImpactFeedbackGenerator(style: .light)
      let impactMedium = UIImpactFeedbackGenerator(style: .medium)
      let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
      let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
      let impactSoft = UIImpactFeedbackGenerator(style: .soft)
      let selectionGenerator = UISelectionFeedbackGenerator()
      let notificationGenerator = UINotificationFeedbackGenerator()

      return Self(
        prepare: { feedback in
          await MainActor.run {
            switch feedback {
            case .impactLight:
              impactLight.prepare()
            case .impactMedium:
              impactMedium.prepare()
            case .impactHeavy:
              impactHeavy.prepare()
            case .impactRigid:
              impactRigid.prepare()
            case .impactSoft:
              impactSoft.prepare()
            case .selection:
              selectionGenerator.prepare()
            case .success, .warning, .error:
              notificationGenerator.prepare()
            }
          }
        },
        generate: { feedback in
          await MainActor.run {
            switch feedback {
            case .impactLight(let intensity):
              impactLight.impactOccurred(intensity: intensity)
            case .impactMedium(let intensity):
              impactMedium.impactOccurred(intensity: intensity)
            case .impactHeavy(let intensity):
              impactHeavy.impactOccurred(intensity: intensity)
            case .impactRigid(let intensity):
              impactRigid.impactOccurred(intensity: intensity)
            case .impactSoft(let intensity):
              impactSoft.impactOccurred(intensity: intensity)
            case .selection:
              selectionGenerator.selectionChanged()
            case .success:
              notificationGenerator.notificationOccurred(.success)
            case .warning:
              notificationGenerator.notificationOccurred(.warning)
            case .error:
              notificationGenerator.notificationOccurred(.error)
            }
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
          await MainActor.run {
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
          await MainActor.run {
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
