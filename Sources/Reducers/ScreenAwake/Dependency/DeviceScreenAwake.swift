import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct DeviceScreenAwake: Sendable {
  public var enable: @MainActor @Sendable () async -> Void
  public var disable: @MainActor @Sendable () async -> Void
}

extension DeviceScreenAwake: TestDependencyKey {
  public static var previewValue: DeviceScreenAwake {
    .noop
  }

  public static var testValue: DeviceScreenAwake {
    .noop
  }

  public static var noop: DeviceScreenAwake {
    .init(
      enable: {},
      disable: {}
    )
  }
}

#if os(iOS) || os(tvOS)
  import UIKit

  extension DeviceScreenAwake: DependencyKey {
    public static var liveValue: DeviceScreenAwake {
      .init(
        enable: {
          guard !Bundle.main.bundlePath.hasSuffix(".appex") else { return }
          guard !UIApplication.shared.isIdleTimerDisabled else { return }
          UIApplication.shared.isIdleTimerDisabled = true
        },
        disable: {
          guard !Bundle.main.bundlePath.hasSuffix(".appex") else { return }
          guard UIApplication.shared.isIdleTimerDisabled else { return }
          UIApplication.shared.isIdleTimerDisabled = false
        }
      )
    }
  }
#endif

#if os(macOS)
  import IOKit.pwr_mgt

  private final class DisplayAssertionStorage: @unchecked Sendable {
    private let lock = NSLock()
    private var _assertionID: IOPMAssertionID = 0

    var assertionID: IOPMAssertionID {
      get {
        lock.lock()
        defer { lock.unlock() }
        return _assertionID
      }
      set {
        lock.lock()
        defer { lock.unlock() }
        _assertionID = newValue
      }
    }
  }

  extension DeviceScreenAwake: DependencyKey {
    public static var liveValue: DeviceScreenAwake {
      let storage = DisplayAssertionStorage()
      return .init(
        enable: {
          guard storage.assertionID == 0 else { return }
          var assertionID: IOPMAssertionID = 0
          let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "ScreenAwake: Keeping display awake" as CFString,
            &assertionID
          )
          if result == kIOReturnSuccess {
            storage.assertionID = assertionID
          }
        },
        disable: {
          let currentID = storage.assertionID
          guard currentID != 0 else { return }
          IOPMAssertionRelease(currentID)
          storage.assertionID = 0
        }
      )
    }
  }
#endif

#if os(watchOS)
  extension DeviceScreenAwake: DependencyKey {
    public static var liveValue: DeviceScreenAwake {
      .noop
    }
  }
#endif

extension DependencyValues {
  public var deviceScreenAwake: DeviceScreenAwake {
    get { self[DeviceScreenAwake.self] }
    set { self[DeviceScreenAwake.self] = newValue }
  }
}
