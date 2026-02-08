#if os(iOS)

  import Foundation

  enum SandboxCheck {
    struct Result: Sendable {
      let compromised: Bool
      let score: Int
    }

    private static let restrictedPaths = [
      "/etc/fstab",
      "/root",
      "/bin/ls",
    ]

    private static let sensitiveFiles = [
      "/etc/passwd",
      "/etc/master.passwd",
    ]

    static func check() -> Result {
      var indicators = 0

      let testPath = "/private/jailbreak_test_\(UUID().uuidString).txt"
      let testData = Data("jailbreak_check".utf8)
      if FileManager.default.createFile(atPath: testPath, contents: testData) {
        indicators += 1
        try? FileManager.default.removeItem(atPath: testPath)
      }

      for path in restrictedPaths {
        if FileManager.default.isReadableFile(atPath: path) {
          indicators += 1
        }
      }

      for path in sensitiveFiles {
        if let file = fopen(path, "r") {
          fclose(file)
          indicators += 1
        }
      }

      let score = indicators > 0 ? 12 : 0

      return Result(
        compromised: indicators > 0,
        score: score
      )
    }
  }

#endif
