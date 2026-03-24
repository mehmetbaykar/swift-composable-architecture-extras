#if os(macOS)

  import Dependencies
  import DependenciesMacros
  import Subprocess

  @DependencyClient
  public struct ShellClient: Sendable {
    public var run: @Sendable (_ command: String) async throws -> ShellResult
  }

  public struct ShellResult: Sendable, Equatable {
    public let stdout: String
    public let stderr: String
    public let exitCode: Int32

    public var succeeded: Bool { exitCode == 0 }

    public init(stdout: String, stderr: String, exitCode: Int32) {
      self.stdout = stdout
      self.stderr = stderr
      self.exitCode = exitCode
    }
  }

#endif
