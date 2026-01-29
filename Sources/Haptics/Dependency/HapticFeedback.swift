import Foundation

public enum HapticFeedback: Sendable, Equatable {

  #if os(iOS)
    case success
    case warning
    case error
    case impactLight(intensity: CGFloat = 1.0)
    case impactMedium(intensity: CGFloat = 1.0)
    case impactHeavy(intensity: CGFloat = 1.0)
    case impactRigid(intensity: CGFloat = 1.0)
    case impactSoft(intensity: CGFloat = 1.0)
    case selection
  #endif

  #if os(macOS)
    case alignment
    case levelChange
    case generic
  #endif

  #if os(watchOS)
    case watchNotification
    case watchDirectionUp
    case watchDirectionDown
    case watchSuccess
    case watchFailure
    case watchRetry
    case watchStart
    case watchStop
    case watchClick
  #endif
}
