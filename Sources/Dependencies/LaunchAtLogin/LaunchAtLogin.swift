#if os(macOS) || targetEnvironment(macCatalyst)

  import Dependencies
  import DependenciesMacros

  @DependencyClient
  public struct LaunchAtLoginClient: Sendable {
    public var isEnabled: @Sendable () -> Bool = { false }
    public var setEnabled: @Sendable (Bool) throws -> Void
    public var wasLaunchedAtLogin: @Sendable () -> Bool = { false }
  }

#endif
