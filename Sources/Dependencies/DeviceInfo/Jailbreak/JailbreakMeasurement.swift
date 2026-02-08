#if os(iOS)

  enum JailbreakMeasurement {
    static func measure() -> JailbreakStatus {
      #if targetEnvironment(simulator)
        return .nominal
      #else
        let filesystem = FilesystemCheck.check()
        let sandbox = SandboxCheck.check()
        let dyld = DyldCheck.check()
        let environment = EnvironmentCheck.check()

        let totalScore =
          filesystem.pathScore
          + filesystem.symlinkScore
          + sandbox.score
          + dyld.score
          + environment.score

        let confidence: JailbreakConfidence
        switch totalScore {
        case 0:
          confidence = .nominal
        case 1...12:
          confidence = .low
        case 13...25:
          confidence = .moderate
        default:
          confidence = .high
        }

        return JailbreakStatus(confidence: confidence)
      #endif
    }
  }

#endif
