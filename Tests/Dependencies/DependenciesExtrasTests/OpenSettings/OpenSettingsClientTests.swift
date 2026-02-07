#if !os(watchOS)

  import Dependencies
  import Testing

  @testable import OpenSettings

  @MainActor
  private final class OpenSettingsRecorder: Sendable {
    nonisolated(unsafe) var calledTypes: [OpenSettingsClient.SettingsType] = []

    var client: OpenSettingsClient {
      OpenSettingsClient(open: { [self] type in
        calledTypes.append(type)
      })
    }
  }

  @Suite("OpenSettingsClient")
  @MainActor
  struct OpenSettingsClientTests {

    @Suite("CustomValues")
    @MainActor
    struct CustomValueTests {

      @Test func `custom implementation receives general`() async {
        let recorder = OpenSettingsRecorder()
        await recorder.client.open(.general)
        #expect(recorder.calledTypes == [.general])
      }

      @Test func `noop does not throw`() async {
        let client = OpenSettingsClient.noop
        await client.open(.general)
      }

      #if os(iOS) || os(macOS) || os(visionOS)
        @Test func `custom implementation receives notifications`() async {
          let recorder = OpenSettingsRecorder()
          await recorder.client.open(.notifications)
          #expect(recorder.calledTypes == [.notifications])
        }
      #endif
    }

    @Suite("WithDependencies")
    @MainActor
    struct WithDependenciesTests {

      @Test func `overridden dependency receives correct settings type`() async {
        let recorder = OpenSettingsRecorder()

        await withDependencies {
          $0.openSettings = recorder.client
        } operation: {
          @Dependency(\.openSettings) var openSettings
          await openSettings.open(.general)
        }

        #expect(recorder.calledTypes == [.general])
      }

      @Test func `noop dependency override does not throw`() async {
        await withDependencies {
          $0.openSettings = .noop
        } operation: {
          @Dependency(\.openSettings) var openSettings
          await openSettings.open(.general)
        }
      }
    }
  }

#endif
