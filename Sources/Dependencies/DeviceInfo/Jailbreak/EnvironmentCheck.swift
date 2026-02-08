#if os(iOS)

  import Foundation

  enum EnvironmentCheck {
    struct Result: Sendable {
      let tampered: Bool
      let score: Int
    }

    private static let suspiciousInsertions = [
      "MobileSubstrate",
      "TweakInject",
      "libhooker",
      "cycript",
      "FridaGadget",
      "SSLKillSwitch",
    ]

    static func check() -> Result {
      guard let envValue = getenv("DYLD_INSERT_LIBRARIES") else {
        return Result(tampered: false, score: 0)
      }

      let value = String(cString: envValue)
      var found = false

      for library in suspiciousInsertions {
        if value.contains(library) {
          found = true
          break
        }
      }

      if !found {
        found = !value.isEmpty
      }

      let score = found ? 8 : 0

      return Result(
        tampered: found,
        score: score
      )
    }
  }

#endif
