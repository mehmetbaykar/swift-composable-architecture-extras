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

    @Test func `umbrella re-exports OpenURL module`() {
      let client = OpenURL.OpenURLClient.noop
      _ = client
    }
  #endif

  @Test func `umbrella re-exports AudioPlayer module`() {
    _ = AudioPlayer.AudioPlayerClient.self
    _ = AudioPlayer.AudioPlayerError.self
  }

  @Test func `umbrella re-exports DeviceInfo module`() async {
    let client = DeviceInfo.DeviceInfoClient.noop
    _ = await client.identity()
  }

  @Test func `umbrella re-exports LoggerClient module`() {
    let client = LoggerClient.AppLoggerClient.noop()
    client.info("test")
  }

  #if os(macOS)
    @Test func `umbrella re-exports ShellClient module`() {
      let client: ShellClient = .noop
      _ = client
    }
  #endif

  #if os(macOS) || targetEnvironment(macCatalyst)
    @Test func `umbrella re-exports LaunchAtLogin module`() {
      let client: LaunchAtLoginClient = .noop
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
