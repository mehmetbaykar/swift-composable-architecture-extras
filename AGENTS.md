# AGENTS.md

## Cursor Cloud specific instructions

This repository is an **Apple-platform-only** Swift Package (iOS 16+, macOS 15+, tvOS 16+,
watchOS 9+). See `CLAUDE.md` and `README.md` for module details and the canonical build/test
commands (`swift build`, `swift test`), and `.github/workflows/ci.yml` for the CI `xcodebuild`
invocations (schemes `ComposableArchitectureExtras` and `AllTests`).

### Build / test / run must happen on macOS + Xcode

There is **no runnable application** — this is a library. The supported dev environment is macOS
with Xcode (Swift 6.3+). Building, testing, and any verification of changes must be done on macOS,
either with `swift build` / `swift test` or the `xcodebuild` commands from the CI workflow.

### The package cannot be built or tested on the Linux Cloud Agent VM

Swift 6.3.3 is installed on this Linux VM (via `swiftly`, on `PATH` through `~/.bashrc` and
`~/.profile`) so editing and syntax tooling work, but the package itself does **not** build on
Linux. This is a platform limitation, not a repo bug — do not try to "fix" it by editing sources.
Concretely:

1. **SwiftPM manifest is not Linux-resolvable.** `Package.swift` gates the `swift-subprocess`
   dependency behind `#if os(macOS)`, while the `ShellClient` target still references it. On a
   non-macOS host `swift package resolve` / `swift build` fail with
   `unknown package 'swift-subprocess' in dependencies of target 'ShellClient'`.
2. **TCA is not Linux-compatible here.** Even a minimal program depending only on
   `swift-composable-architecture` 1.26.0 fails to build on Linux — its transitive
   `SwiftNavigation` uses Apple-only types (`LocalizedStringResource`, SwiftUI `Text`). So no
   subset of this package could build on Linux even if the manifest resolved.
3. **Modules import Apple-only frameworks** (UIKit, IOKit, AVFoundation, `os` / `os.Logger`,
   ServiceManagement/SMAppService, SafariServices, CoreWLAN, OpenDirectory, DeviceKit).

Because of the above, lint/test/build/run verification for changes in this repo requires macOS;
it cannot be demonstrated on this Linux Cloud Agent VM.
