#if os(iOS)

  import Foundation

  enum FilesystemCheck {
    struct Result: Sendable {
      let pathsFound: Bool
      let pathScore: Int
      let symlinksFound: Bool
      let symlinkScore: Int
    }

    private static let jailbreakPaths = [
      "/Applications/Cydia.app",
      "/Applications/Sileo.app",
      "/Applications/Zebra.app",
      "/Library/MobileSubstrate/MobileSubstrate.dylib",
      "/usr/libexec/cydia",
      "/usr/sbin/sshd",
      "/usr/bin/ssh",
      "/usr/sbin/frida-server",
      "/usr/bin/cycript",
      "/var/lib/cydia",
      "/var/lib/apt",
      "/etc/apt",
      "/bin/bash",
      "/bin/sh",
    ]

    private static let symlinkPaths = [
      "/Applications",
      "/var/stash",
      "/var/db/stash",
      "/usr/arm-apple-darwin9",
      "/usr/lib/log",
    ]

    static func check() -> Result {
      let fileManager = FileManager.default
      var pathHits = 0

      for path in jailbreakPaths {
        if fileManager.fileExists(atPath: path) {
          pathHits += 1
        }
      }

      var symlinkHits = 0
      for path in symlinkPaths {
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: path, isDirectory: &isDirectory) {
          if let attributes = try? fileManager.attributesOfItem(atPath: path),
            let type = attributes[.type] as? FileAttributeType,
            type == .typeSymbolicLink
          {
            symlinkHits += 1
          }
        }
      }

      let pathScore = pathHits > 0 ? 15 : 0
      let symlinkScore = symlinkHits > 0 ? 5 : 0

      return Result(
        pathsFound: pathHits > 0,
        pathScore: pathScore,
        symlinksFound: symlinkHits > 0,
        symlinkScore: symlinkScore
      )
    }
  }

#endif
