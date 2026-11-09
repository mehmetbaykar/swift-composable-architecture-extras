# CLAUDE.md

Swift package with reducers and dependencies for The Composable Architecture (TCA 1.x). [README.md](README.md) lists each module with its platforms and usage. Each module also has a `README.md` in its source folder.

## Commands

- Build: `swift build`
- Test: `swift test`
- Clean: `swift package clean`

CI (`.github/workflows/ci.yml`) builds the `ComposableArchitectureExtras` scheme and tests the `AllTests` scheme with `xcodebuild` on iOS, macOS, tvOS, and watchOS.

## Layout

- Each module is one target in `Sources/Reducers/<Module>` or `Sources/Dependencies/<Module>`. `Sources/Reducers` and `Sources/Dependencies` are folders, not targets.
- Products: 3 umbrellas (`ComposableArchitectureExtras`, `ReducersExtras`, `DependenciesExtras`) and one standalone product for each of the 16 modules.
- `ReducersExtras` and `DependenciesExtras` re-export their modules with `@_exported import`. `ComposableArchitectureExtras` re-exports both umbrellas behind the `Reducers` and `Dependencies` package traits.
- To add a module, add a `.singleTargetLibrary(name:)` product and a `reducerTarget(name:)` or `dependencyTarget(name:)` target in `Package.swift`. The target helper adds TCA and excludes the module `README.md`. Then add the module to its umbrella target and to the umbrella `.swift` file.
- Platform-only modules compile on every platform and wrap all code in `#if`: AppStoreOverlay (iOS), ShellClient (macOS), LaunchAtLogin (macOS, Mac Catalyst), OpenSettings and OpenURL (not watchOS). `DependenciesExtras.swift` imports the last four under the same conditions.
- `PrivacyInfo.xcprivacy` is a resource of the `ComposableArchitectureExtras` target only.
- `Tests/AllTests.xctestplan` runs 3 test targets: `ComposableArchitectureExtrasTests`, `ReducersExtrasTests`, and `DependenciesExtrasTests`. Put the tests for a module in `Tests/Reducers/ReducersExtrasTests/<Module>/` or `Tests/Dependencies/DependenciesExtrasTests/<Module>/`.

## Dependencies

- Keep `swift-subprocess` at `0.4.x`. Version 0.5 removed the `SubprocessSpan` trait and breaks resolution.
- DeviceKit is linked only on iOS, tvOS, and watchOS. swift-subprocess is linked only on macOS.
- Use `reportIssue`, not `XCTFail`, in library code, so that the package does not link `XCTestDynamicOverlay` (#13).

## Code conventions

- Do not add `// MARK:` or explanatory comments unless the code cannot explain itself. Do not add a trailing comment to `#endif` unless the nesting is ambiguous.
- Use `@DependencyClient` for a new client, as in `Sources/Dependencies/AppInfo/Dependency/AppInfoClient.swift`. Give the client a `.noop` value for previews and tests. `DeviceInfoClient` is a manual struct because its properties depend on `#if os(...)`.
- Add reducer behavior as a method on `Reducer` that wraps `self`, as in `Sources/Reducers/Filter/Reducer/FilterReducer.swift`.
- `OpenURLClient` uses the key path `\.customOpenURL`, so that it does not shadow TCA's `\.openURL`.
- `AppLoggerClient` is a `TestDependencyKey` with no `liveValue`. Apps choose the destinations with `prepareDependencies`.
- In a reducer `body`, put `BindingReducer()` first, then the feature logic, then utility reducers such as `.filter` and `.haptics`.
- Capture dependencies in effects: `return .run { [dependency] _ in ... }`.
- FormValidation error messages use the form "[Field] should be [condition]", for example "Email should not be empty".

## Tests

- Use Swift Testing (`@Test`, `@Suite`, `#expect`). Test reducers with `TestStore` on `@MainActor`.
- Name tests in natural language with backticks: `` `binding with value below 18 shows error` ``.
- Use `@testable import` only for test fixtures.
- Record dependency calls with a small recorder class, as in `Tests/Reducers/ReducersExtrasTests/ScreenAwake/Mocks/RecordingDeviceScreenAwake.swift`.
- Guard platform-specific tests with `#if os(...)`. ShellClient, LaunchAtLogin, and the macOS DeviceInfo APIs have macOS-only tests.

## CI

- Keep `set -o pipefail` before each `xcodebuild ... | xcpretty`. Without it, a failed build passes.
- Never add `|| true` to a CI step. It hides every failure.
- Keep `-skipMacroValidation`. CI cannot approve the TCA macros.
- Keep `-derivedDataPath .derivedData` on the build and test steps, so that the test step reuses the build.

## Docs

- When you add or change a public API, update the module `README.md` and the module section in the root `README.md`.
- When code for iOS, tvOS, visionOS, or watchOS starts to use a required-reason API, update `Sources/ComposableArchitectureExtras/Resources/PrivacyInfo.xcprivacy` and the Privacy Manifest table in `README.md`.
