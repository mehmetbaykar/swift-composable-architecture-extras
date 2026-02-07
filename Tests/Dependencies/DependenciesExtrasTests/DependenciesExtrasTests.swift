import Dependencies
import Testing

@testable import DependenciesExtras

@Suite("DependenciesExtras")
struct DependenciesExtrasTests {

  @Test func `umbrella re-exports AppInfo module`() {
    let client = AppInfo.AppInfoClient.noop
    _ = client.appVersion()
  }

  #if !os(watchOS)
    @Test func `umbrella re-exports OpenSettings module`() {
      let client = OpenSettings.OpenSettingsClient.noop
      _ = client
    }
  #endif

  @Test func `dependency is accessible via DependencyValues`() {
    withDependencies {
      $0.appInfo = AppInfoClient(
        appVersion: { "1.0.0" },
        buildNumber: { 1 },
        bundleIdentifier: { "com.test" }
      )
    } operation: {
      @Dependency(\.appInfo) var appInfo
      #expect(appInfo.appVersion() == "1.0.0")
    }
  }
}
