#if os(iOS)
  import DeviceKit
  import UIKit

  enum ScreenMeasurement {
    @MainActor
    static func measure() -> ScreenInfo {
      let device = Device.current
      let screen = UIScreen.main
      let bounds = screen.bounds
      let scale = screen.scale
      let nativeBounds = screen.nativeBounds
      let ratio = device.screenRatio
      let ppiValue = device.ppi ?? 0
      let diagonalValue = device.diagonal < 0 ? 0 : device.diagonal

      return ScreenInfo(
        width: bounds.width,
        height: bounds.height,
        scale: scale,
        nativePixelWidth: Int(min(nativeBounds.width, nativeBounds.height)),
        nativePixelHeight: Int(max(nativeBounds.width, nativeBounds.height)),
        screenRatio: ScreenRatio(width: ratio.width, height: ratio.height),
        diagonal: diagonalValue,
        ppi: ppiValue,
        hasNotch: device.hasSensorHousing || device.hasDynamicIsland,
        hasDynamicIsland: device.hasDynamicIsland,
        hasRoundedDisplayCorners: device.hasRoundedDisplayCorners
      )
    }
  }

#elseif os(tvOS)
  import DeviceKit
  import UIKit

  enum ScreenMeasurement {
    @MainActor
    static func measure() -> ScreenInfo {
      let device = Device.current
      let screen = UIScreen.main
      let bounds = screen.bounds
      let scale = screen.scale
      let nativeBounds = screen.nativeBounds
      let ratio = device.screenRatio

      return ScreenInfo(
        width: bounds.width,
        height: bounds.height,
        scale: scale,
        nativePixelWidth: Int(min(nativeBounds.width, nativeBounds.height)),
        nativePixelHeight: Int(max(nativeBounds.width, nativeBounds.height)),
        screenRatio: ScreenRatio(width: ratio.width, height: ratio.height)
      )
    }
  }

#elseif os(watchOS)
  import DeviceKit
  import WatchKit

  enum ScreenMeasurement {
    @MainActor
    static func measure() -> ScreenInfo {
      let device = Device.current
      let wkDevice = WKInterfaceDevice.current()
      let bounds = wkDevice.screenBounds
      let scale = wkDevice.screenScale
      let pixelWidth = bounds.width * scale
      let pixelHeight = bounds.height * scale
      let ratio = device.screenRatio
      let ppiValue = device.ppi ?? 0
      let diagonalValue = device.diagonal < 0 ? 0 : device.diagonal

      return ScreenInfo(
        width: bounds.width,
        height: bounds.height,
        scale: scale,
        nativePixelWidth: Int(min(pixelWidth, pixelHeight).rounded()),
        nativePixelHeight: Int(max(pixelWidth, pixelHeight).rounded()),
        screenRatio: ScreenRatio(width: ratio.width, height: ratio.height),
        diagonal: diagonalValue,
        ppi: ppiValue
      )
    }
  }

#elseif os(macOS)
  import AppKit

  enum ScreenMeasurement {
    @MainActor
    static func measure() -> ScreenInfo {
      guard let screen = NSScreen.main else {
        return .zero
      }
      let frame = screen.frame
      let scale = screen.backingScaleFactor
      let pixelWidth = frame.width * scale
      let pixelHeight = frame.height * scale

      return ScreenInfo(
        width: frame.width,
        height: frame.height,
        scale: scale,
        nativePixelWidth: Int(min(pixelWidth, pixelHeight).rounded()),
        nativePixelHeight: Int(max(pixelWidth, pixelHeight).rounded())
      )
    }
  }
#endif
