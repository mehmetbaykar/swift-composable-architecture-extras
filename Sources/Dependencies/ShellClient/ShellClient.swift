#if os(macOS)

  import Dependencies
  import DependenciesMacros
  import Foundation
  import Subprocess

  /// A dependency client for executing shell commands on macOS.
  ///
  /// Uses Swift's `Subprocess` library for process execution.
  /// All source is wrapped in `#if os(macOS)` — this module compiles
  /// to an empty module on other platforms.
  @DependencyClient
  public struct ShellClient: Sendable {
    /// Executes a shell command and returns the result.
    ///
    /// - Parameter command: The shell command string to execute via `/bin/zsh -c`.
    /// - Returns: A ``ShellResult`` containing stdout, stderr, and exit code.
    /// - Throws: If the subprocess cannot be launched.
    public var run: @Sendable (_ command: String) async throws -> ShellResult
  }

  /// The result of a shell command execution.
  public struct ShellResult: Sendable, Equatable {
    /// The standard output captured from the command.
    public let stdout: String

    /// The standard error output captured from the command.
    public let stderr: String

    /// The process exit code. Zero indicates success.
    public let exitCode: Int32

    /// Whether the command exited with code zero.
    public var succeeded: Bool { exitCode == 0 }

    /// Creates a new shell result.
    ///
    /// - Parameters:
    ///   - stdout: The standard output string.
    ///   - stderr: The standard error string.
    ///   - exitCode: The process exit code.
    public init(stdout: String, stderr: String, exitCode: Int32) {
      self.stdout = stdout
      self.stderr = stderr
      self.exitCode = exitCode
    }
  }

  extension ShellClient: DependencyKey {
    public static var liveValue: ShellClient {
      .init { command in
        let result = try await Subprocess.run(
          .path("/bin/zsh"),
          arguments: ["-c", command],
          output: .string(limit: .max),
          error: .string(limit: .max)
        )
        let exitCode: Int32
        switch result.terminationStatus {
        case .exited(let code):
          exitCode = code
        case .signaled(let code):
          exitCode = code
        }
        return ShellResult(
          stdout: (result.standardOutput ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines),
          stderr: (result.standardError ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines),
          exitCode: exitCode
        )
      }
    }
  }

  extension ShellClient: TestDependencyKey {
    public static var previewValue: ShellClient { .noop }
    public static var testValue: ShellClient { .noop }

    /// A no-op client that returns empty successful results.
    public static var noop: ShellClient {
      .init { _ in ShellResult(stdout: "", stderr: "", exitCode: 0) }
    }
  }

  extension DependencyValues {
    /// A client for executing shell commands on macOS.
    public var shellClient: ShellClient {
      get { self[ShellClient.self] }
      set { self[ShellClient.self] = newValue }
    }
  }

#endif
