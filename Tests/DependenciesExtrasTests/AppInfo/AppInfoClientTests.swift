import Dependencies
import Testing

@testable import AppInfo

@Suite("AppInfoClient")
@MainActor
struct AppInfoClientTests {

  @Suite("CustomValues")
  @MainActor
  struct CustomValueTests {

    @Test func `custom implementation returns expected values`() {
      let client = AppInfoClient(
        appVersion: { "2.0.0" },
        buildNumber: { 42 },
        bundleIdentifier: { "com.example.app" }
      )

      #expect(client.appVersion() == "2.0.0")
      #expect(client.buildNumber() == 42)
      #expect(client.bundleIdentifier() == "com.example.app")
    }

    @Test func `noop returns empty values`() {
      let client = AppInfoClient.noop

      #expect(client.appVersion() == "")
      #expect(client.buildNumber() == 0)
      #expect(client.bundleIdentifier() == nil)
    }
  }

  @Suite("WithDependencies")
  @MainActor
  struct WithDependenciesTests {

    @Test func `overridden dependency returns custom values`() {
      withDependencies {
        $0.appInfo = AppInfoClient(
          appVersion: { "1.5.0" },
          buildNumber: { 100 },
          bundleIdentifier: { "com.test.bundle" }
        )
      } operation: {
        @Dependency(\.appInfo) var appInfo

        #expect(appInfo.appVersion() == "1.5.0")
        #expect(appInfo.buildNumber() == 100)
        #expect(appInfo.bundleIdentifier() == "com.test.bundle")
      }
    }

    @Test func `noop dependency override returns defaults`() {
      withDependencies {
        $0.appInfo = .noop
      } operation: {
        @Dependency(\.appInfo) var appInfo

        #expect(appInfo.appVersion() == "")
        #expect(appInfo.buildNumber() == 0)
        #expect(appInfo.bundleIdentifier() == nil)
      }
    }

    @Test func `partial override only changes specified endpoints`() {
      withDependencies {
        $0.appInfo.appVersion = { "3.0.0" }
      } operation: {
        @Dependency(\.appInfo) var appInfo

        #expect(appInfo.appVersion() == "3.0.0")
      }
    }
  }
}
