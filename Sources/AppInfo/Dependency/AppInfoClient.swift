import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct AppInfoClient: Sendable {
  public var appVersion: @Sendable () -> String = { "" }
  public var buildNumber: @Sendable () -> Int = { 0 }
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
      buildNumber: { 0 },
      bundleIdentifier: { nil }
    )
  }
}

extension AppInfoClient: DependencyKey {
  public static var liveValue: AppInfoClient {
    .bundle(.main)
  }

  public static func bundle(_ bundle: Bundle) -> AppInfoClient {
    let get: @Sendable (String) -> String = {
      bundle.object(forInfoDictionaryKey: $0) as? String ?? ""
    }

    return .init(
      appVersion: {
        get("CFBundleShortVersionString")
      },
      buildNumber: {
        Int(get("CFBundleVersion")) ?? 0
      },
      bundleIdentifier: {
        get("CFBundleIdentifier")
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
