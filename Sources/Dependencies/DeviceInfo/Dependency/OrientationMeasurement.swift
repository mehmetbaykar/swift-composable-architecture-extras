#if os(iOS)

  import UIKit

  enum OrientationMeasurement {
    @MainActor
    static func measure() -> DeviceInterfaceOrientation {
      let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
      let scene = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
      guard let orientation = scene?.interfaceOrientation else { return .unknown }
      switch orientation {
      case .portrait: return .portrait
      case .portraitUpsideDown: return .portraitUpsideDown
      case .landscapeLeft: return .landscapeLeft
      case .landscapeRight: return .landscapeRight
      default: return .unknown
      }
    }
  }

#endif
