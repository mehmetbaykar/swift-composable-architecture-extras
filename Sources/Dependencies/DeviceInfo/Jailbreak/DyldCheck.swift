#if os(iOS)

  import MachO

  enum DyldCheck {
    struct Result: Sendable {
      let suspiciousFound: Bool
      let score: Int
    }

    private static let suspiciousLibraries = [
      "MobileSubstrate",
      "SubstrateLoader",
      "SubstrateInserter",
      "SubstrateBootstrap",
      "TweakInject",
      "libhooker",
      "FridaGadget",
      "frida-agent",
      "SSLKillSwitch",
      "cycript",
      "libcycript",
      "Electra",
      "Chimera",
      "unc0ver",
    ]

    static func check() -> Result {
      let imageCount = _dyld_image_count()
      var hits = 0

      for i in 0..<imageCount {
        guard let imageName = _dyld_get_image_name(i) else { continue }
        let name = String(cString: imageName)
        for library in suspiciousLibraries {
          if name.contains(library) {
            hits += 1
            break
          }
        }
      }

      let score = hits > 0 ? 10 : 0

      return Result(
        suspiciousFound: hits > 0,
        score: score
      )
    }
  }

#endif
