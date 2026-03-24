#if !os(watchOS)

  import Dependencies
  import DependenciesMacros
  import Foundation

  /// A dependency client for opening system settings on the current platform.
  @DependencyClient
  public struct OpenSettingsClient: Sendable {
    /// The type of system settings pane to open.
    public enum SettingsType: Sendable {
      /// The main system settings screen (macOS) or the app's settings bundle (iOS).
      case general

      #if os(iOS) || os(macOS) || os(visionOS)
        /// The notification settings for the current app.
        case notifications
      #endif

      #if os(macOS)
        /// About This Mac / System Information.
        case about

        /// Network settings.
        case network

        /// Wi-Fi settings.
        case wifi

        /// Bluetooth settings.
        case bluetooth

        /// Sound input/output settings.
        case sound

        /// Display resolution and arrangement settings.
        case displays

        /// Storage management.
        case storage

        /// macOS software update.
        case softwareUpdate

        /// Accessibility features.
        case accessibility

        /// Security and privacy settings.
        case security

        /// Privacy sub-pane within Security & Privacy.
        case privacy(PrivacyPane)

        /// Keyboard settings.
        case keyboard

        /// Trackpad settings.
        case trackpad

        /// Mouse settings.
        case mouse

        /// Printers and scanners.
        case printers

        /// Battery and energy settings.
        case battery

        /// Date and time settings.
        case dateAndTime

        /// Sharing and file sharing settings.
        case sharing

        /// Users and groups.
        case users

        /// Spotlight and Siri settings.
        case spotlight

        /// Siri settings (same pane as Spotlight on macOS).
        case siri

        /// Desktop and Dock settings.
        case desktopAndDock

        /// Wallpaper settings.
        case wallpaper

        /// Screen saver settings.
        case screenSaver

        /// Password and account security settings.
        case passwords

        /// Apple ID account settings.
        case appleID

        /// Family Sharing settings.
        case familySharing

        /// Screen Time settings.
        case screenTime

        /// Focus modes settings.
        case focusModes

        /// Appearance (light/dark mode, accent color).
        case appearance

        /// Privacy sub-panes accessible via ``privacy(_:)``.
        public enum PrivacyPane: Sendable {
          /// Location Services.
          case location
          /// Camera access.
          case camera
          /// Microphone access.
          case microphone
          /// Photos library access.
          case photos
          /// Contacts access.
          case contacts
          /// Calendars access.
          case calendars
          /// Reminders access.
          case reminders
          /// Full Disk Access.
          case fullDiskAccess
          /// Accessibility API access.
          case accessibility
          /// Input monitoring (keystroke access).
          case inputMonitoring
          /// Screen recording and capture.
          case screenRecording
          /// Automation (AppleScript/Accessibility control).
          case automation
          /// Developer tools access.
          case developerTools
          /// Analytics and improvements data sharing.
          case analytics
        }
      #endif
    }

    /// Opens the specified system settings pane.
    public var open: @MainActor @Sendable (SettingsType) async -> Void
  }

  extension OpenSettingsClient: TestDependencyKey {
    public static var previewValue: OpenSettingsClient { .noop }
    public static var testValue: OpenSettingsClient { .noop }
    public static var noop: OpenSettingsClient { .init(open: { _ in }) }
  }

  extension DependencyValues {
    /// A client for opening system settings panes.
    public var openSettings: OpenSettingsClient {
      get { self[OpenSettingsClient.self] }
      set { self[OpenSettingsClient.self] = newValue }
    }
  }

  #if os(iOS) || os(visionOS)
    import UIKit

    extension OpenSettingsClient: DependencyKey {
      public static var liveValue: Self {
        return Self { type in
          guard let url = type.url else { return }
          await UIApplication.shared.open(url)
        }
      }
    }

    extension OpenSettingsClient.SettingsType {
      fileprivate var url: URL? {
        switch self {
        case .general:
          return URL(string: UIApplication.openSettingsURLString)
        case .notifications:
          if #available(iOS 16.0, *) {
            return URL(string: UIApplication.openNotificationSettingsURLString)
          } else {
            return URL(string: UIApplication.openSettingsURLString)
          }
        }
      }
    }

  #elseif os(macOS)
    import AppKit

    extension OpenSettingsClient: DependencyKey {
      public static var liveValue: Self {
        return Self { type in
          guard let url = type.url else { return }
          NSWorkspace.shared.open(url)
        }
      }
    }

    extension OpenSettingsClient.SettingsType {
      fileprivate var url: URL? {
        switch self {
        case .general:
          return URL(string: "x-apple.systempreferences:")
        case .notifications:
          let bundleId = Bundle.main.bundleIdentifier ?? ""
          return URL(
            string:
              "x-apple.systempreferences:com.apple.Notifications-Settings.extension?id=\(bundleId)")
        case .about:
          return URL(string: "x-apple.systempreferences:com.apple.SystemProfiler.AboutExtension")
        case .network:
          return URL(string: "x-apple.systempreferences:com.apple.Network-Settings.extension")
        case .wifi:
          return URL(string: "x-apple.systempreferences:com.apple.wifi-settings-extension")
        case .bluetooth:
          return URL(string: "x-apple.systempreferences:com.apple.BluetoothSettings")
        case .sound:
          return URL(string: "x-apple.systempreferences:com.apple.Sound-Settings.extension")
        case .displays:
          return URL(string: "x-apple.systempreferences:com.apple.Displays-Settings.extension")
        case .storage:
          return URL(string: "x-apple.systempreferences:com.apple.settings.Storage")
        case .softwareUpdate:
          return URL(string: "x-apple.systempreferences:com.apple.preferences.softwareupdate")
        case .accessibility:
          return URL(string: "x-apple.systempreferences:com.apple.Accessibility-Settings.extension")
        case .security:
          return URL(
            string: "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension")
        case .privacy(let pane):
          return pane.url
        case .keyboard:
          return URL(string: "x-apple.systempreferences:com.apple.Keyboard-Settings.extension")
        case .trackpad:
          return URL(string: "x-apple.systempreferences:com.apple.Trackpad-Settings.extension")
        case .mouse:
          return URL(string: "x-apple.systempreferences:com.apple.Mouse-Settings.extension")
        case .printers:
          return URL(string: "x-apple.systempreferences:com.apple.Print-Scan-Settings.extension")
        case .battery:
          return URL(string: "x-apple.systempreferences:com.apple.settings.battery")
        case .dateAndTime:
          return URL(string: "x-apple.systempreferences:com.apple.Date-Time-Settings.extension")
        case .sharing:
          return URL(string: "x-apple.systempreferences:com.apple.Sharing-Settings.extension")
        case .users:
          return URL(string: "x-apple.systempreferences:com.apple.Users-Groups-Settings.extension")
        case .spotlight:
          return URL(
            string: "x-apple.systempreferences:com.apple.Siri-Spotlight-Settings.extension")
        case .siri:
          return URL(
            string: "x-apple.systempreferences:com.apple.Siri-Spotlight-Settings.extension")
        case .desktopAndDock:
          return URL(string: "x-apple.systempreferences:com.apple.Desktop-Settings.extension")
        case .wallpaper:
          return URL(string: "x-apple.systempreferences:com.apple.Wallpaper-Settings.extension")
        case .screenSaver:
          return URL(string: "x-apple.systempreferences:com.apple.ScreenSaver-Settings.extension")
        case .passwords:
          return URL(string: "x-apple.systempreferences:com.apple.preferences.password")
        case .appleID:
          return URL(string: "x-apple.systempreferences:com.apple.preferences.AppleIDPrefPane")
        case .familySharing:
          return URL(
            string: "x-apple.systempreferences:com.apple.preferences.FamilySharingPrefPane")
        case .screenTime:
          return URL(string: "x-apple.systempreferences:com.apple.Screen-Time-Settings.extension")
        case .focusModes:
          return URL(string: "x-apple.systempreferences:com.apple.Focus-Settings.extension")
        case .appearance:
          return URL(string: "x-apple.systempreferences:com.apple.Appearance-Settings.extension")
        }
      }
    }

    extension OpenSettingsClient.SettingsType.PrivacyPane {
      fileprivate var url: URL? {
        let base = "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension"
        switch self {
        case .location:
          return URL(string: "\(base)?Privacy_LocationServices")
        case .camera:
          return URL(string: "\(base)?Privacy_Camera")
        case .microphone:
          return URL(string: "\(base)?Privacy_Microphone")
        case .photos:
          return URL(string: "\(base)?Privacy_Photos")
        case .contacts:
          return URL(string: "\(base)?Privacy_Contacts")
        case .calendars:
          return URL(string: "\(base)?Privacy_Calendars")
        case .reminders:
          return URL(string: "\(base)?Privacy_Reminders")
        case .fullDiskAccess:
          return URL(string: "\(base)?Privacy_AllFiles")
        case .accessibility:
          return URL(string: "\(base)?Privacy_Accessibility")
        case .inputMonitoring:
          return URL(string: "\(base)?Privacy_ListenEvent")
        case .screenRecording:
          return URL(string: "\(base)?Privacy_ScreenCapture")
        case .automation:
          return URL(string: "\(base)?Privacy_Automation")
        case .developerTools:
          return URL(string: "\(base)?Privacy_DevTools")
        case .analytics:
          return URL(string: "\(base)?Privacy_Analytics")
        }
      }
    }

  #elseif os(tvOS)
    import UIKit

    extension OpenSettingsClient: DependencyKey {
      public static var liveValue: Self {
        return Self { type in
          guard let url = type.url else { return }
          await UIApplication.shared.open(url)
        }
      }
    }

    extension OpenSettingsClient.SettingsType {
      fileprivate var url: URL? {
        switch self {
        case .general:
          return URL(string: UIApplication.openSettingsURLString)
        }
      }
    }

  #endif

#endif
