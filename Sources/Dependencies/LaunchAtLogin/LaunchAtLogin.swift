#if os(macOS) || targetEnvironment(macCatalyst)

  import Dependencies
  import DependenciesMacros
  import OSLog
  import ServiceManagement
  import SwiftUI

  /// A dependency client for managing launch-at-login behavior on macOS.
  ///
  /// Uses `SMAppService.mainApp` to register/unregister the app as a login item.
  /// Based on [LaunchAtLogin-Modern](https://github.com/sindresorhus/LaunchAtLogin-Modern).
  @DependencyClient
  public struct LaunchAtLoginClient: Sendable {
    /// Whether the app is currently registered to launch at login.
    public var isEnabled: @Sendable () -> Bool = { false }

    /// Enables or disables launch-at-login registration.
    ///
    /// - Parameter enabled: `true` to register, `false` to unregister.
    /// - Throws: If `SMAppService` registration or unregistration fails.
    public var setEnabled: @Sendable (Bool) throws -> Void

    /// Whether the current app launch was triggered by the login item mechanism.
    ///
    /// Must only be checked in `NSApplicationDelegate.applicationDidFinishLaunching`.
    public var wasLaunchedAtLogin: @Sendable () -> Bool = { false }
  }

  private let launchAtLoginLogger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "LaunchAtLogin",
    category: "LaunchAtLogin"
  )

  extension LaunchAtLoginClient: DependencyKey {
    public static var liveValue: LaunchAtLoginClient {
      .init(
        isEnabled: { SMAppService.mainApp.status == .enabled },
        setEnabled: { newValue in
          do {
            if newValue {
              if SMAppService.mainApp.status == .enabled {
                try? SMAppService.mainApp.unregister()
              }
              try SMAppService.mainApp.register()
            } else {
              try SMAppService.mainApp.unregister()
            }
          } catch {
            launchAtLoginLogger.error(
              "Failed to \(newValue ? "enable" : "disable") launch at login: \(error.localizedDescription)"
            )
            throw error
          }
        },
        wasLaunchedAtLogin: {
          let event = NSAppleEventManager.shared().currentAppleEvent
          return event?.eventID == kAEOpenApplication
            && event?.paramDescriptor(forKeyword: keyAEPropData)?.enumCodeValue
              == keyAELaunchedAsLogInItem
        }
      )
    }
  }

  extension LaunchAtLoginClient: TestDependencyKey {
    public static var previewValue: LaunchAtLoginClient { .noop }
    public static var testValue: LaunchAtLoginClient { .noop }

    /// A no-op client that reports launch-at-login as disabled.
    public static var noop: LaunchAtLoginClient {
      .init(
        isEnabled: { false },
        setEnabled: { _ in },
        wasLaunchedAtLogin: { false }
      )
    }
  }

  extension DependencyValues {
    /// A client for managing launch-at-login behavior on macOS.
    public var launchAtLogin: LaunchAtLoginClient {
      get { self[LaunchAtLoginClient.self] }
      set { self[LaunchAtLoginClient.self] = newValue }
    }
  }

  extension LaunchAtLoginClient {
    /// A SwiftUI toggle view that controls launch-at-login registration.
    public struct Toggle<Label: View>: View {
      @Dependency(\.launchAtLogin) var launchAtLogin
      @State private var isEnabled = false
      private let label: Label

      /// Creates a toggle with a custom label view.
      ///
      /// - Parameter label: A view builder that produces the toggle's label.
      public init(@ViewBuilder label: () -> Label) {
        self.label = label()
      }

      public var body: some View {
        SwiftUI.Toggle(isOn: $isEnabled) { label }
          .onAppear { isEnabled = launchAtLogin.isEnabled() }
          .onChange(of: isEnabled) { _, newValue in
            try? launchAtLogin.setEnabled(newValue)
          }
      }
    }
  }

  extension LaunchAtLoginClient.Toggle where Label == Text {
    /// Creates a toggle with a localized string key as its label.
    ///
    /// - Parameter titleKey: The localized string key for the toggle label.
    public init(_ titleKey: LocalizedStringKey) {
      label = Text(titleKey)
    }

    /// Creates a toggle with a string as its label.
    ///
    /// - Parameter title: The string for the toggle label.
    public init(_ title: some StringProtocol) {
      label = Text(title)
    }

    /// Creates a toggle with the default title of "Launch at login".
    public init() {
      self.init("Launch at login")
    }
  }

#endif
