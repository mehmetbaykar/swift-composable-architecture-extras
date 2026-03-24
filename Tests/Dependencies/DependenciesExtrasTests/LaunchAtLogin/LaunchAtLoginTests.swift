#if os(macOS) || targetEnvironment(macCatalyst)

  import Dependencies
  import Testing

  @testable import LaunchAtLogin

  @Suite("LaunchAtLoginClient")
  struct LaunchAtLoginTests {

    @Suite("Noop")
    struct NoopTests {

      @Test func `noop isEnabled returns false`() {
        let client = LaunchAtLoginClient.noop
        #expect(!client.isEnabled())
      }

      @Test func `noop wasLaunchedAtLogin returns false`() {
        let client = LaunchAtLoginClient.noop
        #expect(!client.wasLaunchedAtLogin())
      }

      @Test func `noop setEnabled does not throw`() throws {
        let client = LaunchAtLoginClient.noop
        try client.setEnabled(true)
        try client.setEnabled(false)
      }
    }

    @Suite("CustomValues")
    struct CustomValueTests {

      @Test func `custom client tracks setEnabled calls`() throws {
        nonisolated(unsafe) var calls: [Bool] = []
        let client = LaunchAtLoginClient(
          isEnabled: { false },
          setEnabled: { calls.append($0) },
          wasLaunchedAtLogin: { false }
        )
        try client.setEnabled(true)
        try client.setEnabled(false)
        #expect(calls == [true, false])
      }

      @Test func `custom client returns configured isEnabled`() {
        let client = LaunchAtLoginClient(
          isEnabled: { true },
          setEnabled: { _ in },
          wasLaunchedAtLogin: { false }
        )
        #expect(client.isEnabled())
      }

      @Test func `custom client returns configured wasLaunchedAtLogin`() {
        let client = LaunchAtLoginClient(
          isEnabled: { false },
          setEnabled: { _ in },
          wasLaunchedAtLogin: { true }
        )
        #expect(client.wasLaunchedAtLogin())
      }
    }

    @Suite("WithDependencies")
    struct WithDependenciesTests {

      @Test func `dependency key path resolves`() {
        withDependencies {
          $0.launchAtLogin = .noop
        } operation: {
          @Dependency(\.launchAtLogin) var launchAtLogin
          #expect(!launchAtLogin.isEnabled())
        }
      }

      @Test func `overridden dependency returns custom isEnabled`() {
        withDependencies {
          $0.launchAtLogin = .init(
            isEnabled: { true },
            setEnabled: { _ in },
            wasLaunchedAtLogin: { false }
          )
        } operation: {
          @Dependency(\.launchAtLogin) var launchAtLogin
          #expect(launchAtLogin.isEnabled())
        }
      }
    }
  }

#endif
