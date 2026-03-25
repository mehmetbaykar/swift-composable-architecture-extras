#if !os(watchOS)

  import Dependencies
  import Testing

  @testable import OpenSettings

  @MainActor
  private final class OpenSettingsRecorder: Sendable {
    nonisolated(unsafe) var callCount = 0

    var client: OpenSettingsClient {
      OpenSettingsClient(open: { [self] _ in
        callCount += 1
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
        #expect(recorder.callCount == 1)
      }

      @Test func `noop does not throw`() async {
        let client = OpenSettingsClient.noop
        await client.open(.general)
      }

      #if os(iOS) || os(macOS) || os(visionOS)
        @Test func `custom implementation receives notifications`() async {
          let recorder = OpenSettingsRecorder()
          await recorder.client.open(.notifications)
          #expect(recorder.callCount == 1)
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

        #expect(recorder.callCount == 1)
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

    #if os(macOS)
      @Suite("macOS Panes")
      @MainActor
      struct MacOSPaneTests {

        @Test func `recorder receives macOS pane calls`() async {
          let recorder = OpenSettingsRecorder()
          await recorder.client.open(.softwareUpdate)
          await recorder.client.open(.about)
          await recorder.client.open(.wifi)
          #expect(recorder.callCount == 3)
        }

        @Test func `noop handles all macOS panes without throwing`() async {
          let client = OpenSettingsClient.noop
          await client.open(.about)
          await client.open(.network)
          await client.open(.wifi)
          await client.open(.bluetooth)
          await client.open(.sound)
          await client.open(.displays)
          await client.open(.storage)
          await client.open(.softwareUpdate)
          await client.open(.accessibility)
          await client.open(.security)
          await client.open(.keyboard)
          await client.open(.passwords)
          await client.open(.appearance)
        }

        @Test func `noop handles privacy sub-panes without throwing`() async {
          let client = OpenSettingsClient.noop
          await client.open(.privacy(.location))
          await client.open(.privacy(.camera))
          await client.open(.privacy(.microphone))
          await client.open(.privacy(.fullDiskAccess))
          await client.open(.privacy(.screenRecording))
        }
      }
    #endif
  }

#endif
