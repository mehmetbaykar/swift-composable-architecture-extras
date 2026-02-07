import Dependencies
import Testing

@testable import DependenciesExtras

@Suite("DependenciesExtras")
struct DependenciesExtrasTests {

  @Test func `umbrella re-exports AppInfo module`() {
    // Verify AppInfoClient is accessible through the umbrella
    let client = AppInfo.AppInfoClient.noop
    _ = client.appVersion()
  }

  @Test func `dependency is accessible via DependencyValues`() {
    withDependencies {
      $0.appInfo = AppInfoClient(
        appVersion: { "1.0.0" },
        buildNumber: { "1" },
        bundleIdentifier: { "com.test" }
      )
    } operation: {
      @Dependency(\.appInfo) var appInfo
      #expect(appInfo.appVersion() == "1.0.0")
    }
  }
}
