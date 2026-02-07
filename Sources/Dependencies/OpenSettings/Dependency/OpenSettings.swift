#if !os(watchOS)

  import Dependencies
  import DependenciesMacros
  import Foundation

  @DependencyClient
  public struct OpenSettingsClient: Sendable {
    public enum SettingsType: Sendable {
      case general

      #if os(iOS) || os(macOS) || os(visionOS)
        case notifications
      #endif
    }

    public var open: @MainActor @Sendable (SettingsType) async -> Void
  }

  extension OpenSettingsClient: TestDependencyKey {
    public static var previewValue: OpenSettingsClient {
      .noop
    }

    public static var testValue: OpenSettingsClient {
      .noop
    }

    public static var noop: OpenSettingsClient {
      .init(open: { _ in })
    }
  }

  extension DependencyValues {
    public var openSettings: OpenSettingsClient {
      get { self[OpenSettingsClient.self] }
      set { self[OpenSettingsClient.self] = newValue }
    }
  }

  #if os(iOS) || os(visionOS)
    import UIKit

    extension OpenSettingsClient: DependencyKey {
      public static var liveValue: Self {
        return Self { type in
          guard let url = type.url else { return }
          await UIApplication.shared.open(url)
        }
      }
    }

    extension OpenSettingsClient.SettingsType {
      fileprivate var url: URL? {
        switch self {
        case .general:
          return URL(string: UIApplication.openSettingsURLString)
        case .notifications:
          if #available(iOS 16.0, *) {
            return URL(string: UIApplication.openNotificationSettingsURLString)
          } else {
            return URL(string: UIApplication.openSettingsURLString)
          }
        }
      }
    }

  #elseif os(macOS)
    import AppKit

    extension OpenSettingsClient: DependencyKey {
      public static var liveValue: Self {
        return Self { type in
          guard let url = type.url else { return }
          NSWorkspace.shared.open(url)
        }
      }
    }

    extension OpenSettingsClient.SettingsType {
      fileprivate var url: URL? {
        switch self {
        case .general:
          return URL(string: "x-apple.systempreferences:")
        case .notifications:
          let bundleId = Bundle.main.bundleIdentifier ?? ""
          return URL(
            string:
              "x-apple.systempreferences:com.apple.Notifications-Settings.extension?id=\(bundleId)"
          )
        }
      }
    }

  #elseif os(tvOS)
    import UIKit

    extension OpenSettingsClient: DependencyKey {
      public static var liveValue: Self {
        return Self { type in
          guard let url = type.url else { return }
          await UIApplication.shared.open(url)
        }
      }
    }

    extension OpenSettingsClient.SettingsType {
      fileprivate var url: URL? {
        switch self {
        case .general:
          return URL(string: UIApplication.openSettingsURLString)
        }
      }
    }

  #endif

#endif
