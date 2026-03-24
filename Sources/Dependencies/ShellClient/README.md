# ShellClient

A macOS-only TCA dependency for executing shell commands.

## Overview

`ShellClient` provides a testable interface for running shell commands via
`/bin/zsh -c` and capturing the output. Each invocation returns a
`ShellResult` containing stdout, stderr, and the process exit code.
Built on [swift-subprocess](https://github.com/swiftlang/swift-subprocess)
for modern Swift process management.

All source is wrapped in `#if os(macOS)` -- this module compiles to an
empty module on other platforms.

## Usage

### Access in a Reducer

```swift
@Reducer
struct MyFeature {
  @ObservableState
  struct State: Equatable {
    var gitBranch: String = ""
    var errorMessage: String?
  }

  enum Action {
    case fetchBranch
  }

  @Dependency(\.shellClient) var shellClient

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchBranch:
        return .run { [shellClient] send in
          let result = try await shellClient.run("git rev-parse --abbrev-ref HEAD")
          if result.succeeded {
            await send(.branchLoaded(result.stdout))
          } else {
            await send(.branchFailed(result.stderr))
          }
        }
      }
    }
  }
}
```

### Testing

```swift
let store = TestStore(initialState: MyFeature.State()) {
  MyFeature()
} withDependencies: {
  $0.shellClient = ShellClient(
    run: { command in
      ShellResult(stdout: "main", stderr: "", exitCode: 0)
    }
  )
}
```

You can also use the built-in `.noop` client, which returns empty successful results:

```swift
$0.shellClient = .noop
```

## API

| Property | Type | Description |
|----------|------|-------------|
| `run` | `@Sendable (String) async throws -> ShellResult` | Executes a shell command via `/bin/zsh -c` and returns the result |

### ShellResult

| Property | Type | Description |
|----------|------|-------------|
| `stdout` | `String` | Standard output captured from the command (whitespace-trimmed) |
| `stderr` | `String` | Standard error output captured from the command (whitespace-trimmed) |
| `exitCode` | `Int32` | Process exit code (zero indicates success) |
| `succeeded` | `Bool` | Computed: whether the command exited with code zero |

## Platform Support

| Platform | Support |
|----------|---------|
| macOS | Full support |
| iOS | Empty module (compiles, no API) |
| tvOS | Empty module (compiles, no API) |
| watchOS | Empty module (compiles, no API) |

## Notes

- **Security**: `ShellClient` executes arbitrary shell commands. Only use with trusted, validated input. Never pass unsanitized user input to `run`.
- **Process backend**: Uses [swift-subprocess](https://github.com/swiftlang/swift-subprocess) (`Subprocess.run`) for process execution rather than the deprecated `Process`/`NSTask` API.
- **Shell**: Commands are executed via `/bin/zsh -c`, matching the default macOS shell.
- **Output trimming**: Both `stdout` and `stderr` are trimmed of leading/trailing whitespace and newlines before being returned.
