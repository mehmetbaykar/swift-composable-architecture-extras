#if os(macOS)

  import Dependencies
  import Testing

  @testable import ShellClient

  @Suite("ShellClient")
  struct ShellClientTests {

    @Suite("ShellResult")
    struct ShellResultTests {

      @Test func `succeeded is true for zero exit code`() {
        let result = ShellResult(stdout: "ok", stderr: "", exitCode: 0)
        #expect(result.succeeded)
      }

      @Test func `succeeded is false for non-zero exit code`() {
        let result = ShellResult(stdout: "", stderr: "error", exitCode: 1)
        #expect(!result.succeeded)
      }

      @Test func `succeeded is false for negative exit code`() {
        let result = ShellResult(stdout: "", stderr: "", exitCode: -1)
        #expect(!result.succeeded)
      }

      @Test func `stores stdout and stderr`() {
        let result = ShellResult(stdout: "output data", stderr: "warning", exitCode: 0)
        #expect(result.stdout == "output data")
        #expect(result.stderr == "warning")
        #expect(result.exitCode == 0)
      }

      @Test func `equatable compares all fields`() {
        let a = ShellResult(stdout: "ok", stderr: "", exitCode: 0)
        let b = ShellResult(stdout: "ok", stderr: "", exitCode: 0)
        let c = ShellResult(stdout: "ok", stderr: "", exitCode: 1)
        #expect(a == b)
        #expect(a != c)
      }
    }

    @Suite("Noop")
    struct NoopTests {

      @Test func `noop returns empty successful result`() async throws {
        let result = try await ShellClient.noop.run("echo hello")
        #expect(result.stdout == "")
        #expect(result.stderr == "")
        #expect(result.exitCode == 0)
        #expect(result.succeeded)
      }

      @Test func `noop ignores command content`() async throws {
        let result = try await ShellClient.noop.run("rm -rf /")
        #expect(result.succeeded)
        #expect(result.stdout == "")
      }
    }

    @Suite("CustomValues")
    struct CustomValueTests {

      @Test func `custom client captures commands`() async throws {
        nonisolated(unsafe) var commands: [String] = []
        let client = ShellClient { command in
          commands.append(command)
          return ShellResult(stdout: "output", stderr: "", exitCode: 0)
        }
        let result = try await client.run("ls -la")
        #expect(commands == ["ls -la"])
        #expect(result.stdout == "output")
      }

      @Test func `custom client can return failure`() async throws {
        let client = ShellClient { _ in
          ShellResult(stdout: "", stderr: "command not found", exitCode: 127)
        }
        let result = try await client.run("nonexistent")
        #expect(!result.succeeded)
        #expect(result.stderr == "command not found")
        #expect(result.exitCode == 127)
      }
    }

    @Suite("WithDependencies")
    struct WithDependenciesTests {

      @Test func `dependency key path resolves`() {
        withDependencies {
          $0.shellClient = .noop
        } operation: {
          @Dependency(\.shellClient) var shellClient
          _ = shellClient
        }
      }

      @Test func `overridden dependency returns custom result`() async throws {
        try await withDependencies {
          $0.shellClient = .init { _ in
            ShellResult(stdout: "custom output", stderr: "", exitCode: 0)
          }
        } operation: {
          @Dependency(\.shellClient) var shellClient
          let result = try await shellClient.run("test")
          #expect(result.stdout == "custom output")
        }
      }
    }

    @Suite("ShellResult Edge Cases")
    struct ShellResultEdgeCaseTests {

      @Test func `ShellResult with negative exit code`() {
        let result = ShellResult(stdout: "", stderr: "Killed", exitCode: -9)
        #expect(!result.succeeded)
        #expect(result.exitCode == -9)
      }

      @Test func `ShellResult with large exit code`() {
        let result = ShellResult(stdout: "", stderr: "Segfault", exitCode: 139)
        #expect(!result.succeeded)
      }

      @Test func `ShellResult equatable differs on stderr`() {
        let a = ShellResult(stdout: "hello", stderr: "", exitCode: 0)
        let c = ShellResult(stdout: "hello", stderr: "warn", exitCode: 0)
        #expect(a != c)
      }
    }

    @Suite("CustomValue Edge Cases")
    struct CustomValueEdgeCaseTests {

      @Test func `custom client with stderr output`() async throws {
        let client = ShellClient { _ in
          ShellResult(stdout: "", stderr: "command not found", exitCode: 127)
        }
        let result = try await client.run("nonexistent_command")
        #expect(!result.succeeded)
        #expect(result.stderr == "command not found")
        #expect(result.exitCode == 127)
      }

      @Test func `custom client with both stdout and stderr`() async throws {
        let client = ShellClient { _ in
          ShellResult(stdout: "partial output", stderr: "warning: deprecated", exitCode: 0)
        }
        let result = try await client.run("some_command")
        #expect(result.succeeded)
        #expect(!result.stdout.isEmpty)
        #expect(!result.stderr.isEmpty)
      }
    }
  }

#endif
