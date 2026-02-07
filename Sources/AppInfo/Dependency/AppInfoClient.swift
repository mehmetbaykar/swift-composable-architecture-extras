import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct AppInfoClient: Sendable {
  public var appVersion: @Sendable () -> String = { "" }
  public var buildNumber: @Sendable () -> String = { "" }
  public var bundleIdentifier: @Sendable () -> String? = { nil }
}

extension AppInfoClient: TestDependencyKey {
  public static var previewValue: AppInfoClient {
    .noop
  }

  public static var testValue: AppInfoClient {
    .noop
  }

  public static var noop: AppInfoClient {
    .init(
      appVersion: { "" },
      buildNumber: { "" },
      bundleIdentifier: { nil }
    )
  }
}

extension AppInfoClient: DependencyKey {
  public static var liveValue: AppInfoClient {
    AppInfoClient(
      appVersion: {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
      },
      buildNumber: {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
      },
      bundleIdentifier: {
        Bundle.main.bundleIdentifier
      }
    )
  }
}

extension DependencyValues {
  public var appInfo: AppInfoClient {
    get { self[AppInfoClient.self] }
    set { self[AppInfoClient.self] = newValue }
  }
}
