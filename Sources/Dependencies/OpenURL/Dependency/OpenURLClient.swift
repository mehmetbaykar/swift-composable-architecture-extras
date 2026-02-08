#if !os(watchOS)

  import Dependencies
  import Foundation

  public struct OpenURLClient: Sendable {
    public var open: @MainActor @Sendable (URL) async -> Bool

    #if os(iOS)
      public var openInApp: @MainActor @Sendable (URL) async -> Bool

      public init(
        open: @escaping @MainActor @Sendable (URL) async -> Bool,
        openInApp: @escaping @MainActor @Sendable (URL) async -> Bool
      ) {
        self.open = open
        self.openInApp = openInApp
      }
    #else
      public init(
        open: @escaping @MainActor @Sendable (URL) async -> Bool
      ) {
        self.open = open
      }
    #endif
  }

  extension OpenURLClient {
    @MainActor
    @discardableResult
    public func callAsFunction(_ url: URL) async -> Bool {
      await open(url)
    }

    #if os(iOS)
      @MainActor
      @discardableResult
      public func callAsFunction(_ url: URL, prefersInApp: Bool) async -> Bool {
        if prefersInApp {
          return await openInApp(url)
        }
        return await open(url)
      }
    #endif
  }

  extension OpenURLClient: TestDependencyKey {
    public static var previewValue: OpenURLClient {
      .noop
    }

    public static var testValue: OpenURLClient {
      .noop
    }

    public static var noop: OpenURLClient {
      #if os(iOS)
        .init(
          open: { _ in true },
          openInApp: { _ in true }
        )
      #else
        .init(open: { _ in true })
      #endif
    }
  }

  extension DependencyValues {
    public var customOpenURL: OpenURLClient {
      get { self[OpenURLClient.self] }
      set { self[OpenURLClient.self] = newValue }
    }
  }

  #if os(iOS)
    import SafariServices
    import UIKit

    extension OpenURLClient: DependencyKey {
      public static var liveValue: Self {
        Self(
          open: { url in
            await UIApplication.shared.open(url)
          },
          openInApp: { url in
            guard
              let viewController = UIApplication.firstKeyWindow?.rootViewController?
                .topMostViewController
            else {
              return await UIApplication.shared.open(url)
            }
            let safari = SFSafariViewController(url: url)
            viewController.present(safari, animated: true)
            return true
          }
        )
      }
    }

    extension UIApplication {
      fileprivate static var firstKeyWindow: UIWindow? {
        shared.connectedScenes
          .compactMap { $0 as? UIWindowScene }
          .flatMap(\.windows)
          .first(where: \.isKeyWindow)
      }
    }

    extension UIViewController {
      fileprivate var topMostViewController: UIViewController {
        if let presented = presentedViewController {
          return presented.topMostViewController
        }
        if let nav = self as? UINavigationController,
          let visible = nav.visibleViewController
        {
          return visible.topMostViewController
        }
        if let tab = self as? UITabBarController,
          let selected = tab.selectedViewController
        {
          return selected.topMostViewController
        }
        return self
      }
    }

  #elseif os(macOS)
    import AppKit

    extension OpenURLClient: DependencyKey {
      public static var liveValue: Self {
        Self(open: { url in
          NSWorkspace.shared.open(url)
        })
      }
    }

  #elseif os(tvOS)
    import UIKit

    extension OpenURLClient: DependencyKey {
      public static var liveValue: Self {
        Self(open: { url in
          await UIApplication.shared.open(url)
        })
      }
    }

  #elseif os(visionOS)
    import UIKit

    extension OpenURLClient: DependencyKey {
      public static var liveValue: Self {
        Self(open: { url in
          await UIApplication.shared.open(url)
        })
      }
    }

  #endif

#endif
