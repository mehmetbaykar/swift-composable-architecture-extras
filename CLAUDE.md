# CLAUDE.md

## Project Description
<!-- AUTO-MANAGED: project-description -->
Swift Composable Architecture Extras - A Swift Package providing production-ready reducer patterns, dependencies, and utilities for TCA applications. Exposes 19 products: 3 umbrellas (**ComposableArchitectureExtras**, **ReducersExtras**, **DependenciesExtras**) and 16 standalone modules. Includes: **Analytics** (event tracking), **AppInfo** (bundle metadata), **AppStoreOverlay** (state-driven App Store overlay, iOS only), **AudioPlayer** (cross-platform audio playback), **DeviceInfo** (device system information + core counts + low power mode + isiOSAppOnMac + screen info + jailbreak detection + hostname + boot time + macOS serial/model/updates), **Filter** (conditional execution), **FormValidation** (declarative validation), **Haptics** (universal haptic feedback), **LaunchAtLogin** (macOS launch-at-login via SMAppService), **LoggerClient** (composable logging with console + file destinations), **OpenSettings** (system settings navigation with ~30 macOS panes), **OpenURL** (URL opening with in-app browsing), **Printers** (debug output), **ScreenAwake** (display management), **ScreenBrightness** (brightness control), and **ShellClient** (macOS shell command execution via swift-subprocess).
<!-- END AUTO-MANAGED -->

## Build Commands
<!-- AUTO-MANAGED: build-commands -->
- Build: `swift build`
- Test: `swift test`
- Clean: `swift package clean`
<!-- END AUTO-MANAGED -->

## Package Configuration
<!-- AUTO-MANAGED: package-config -->
- **Products** (19 total):
  - **Umbrellas**: `ComposableArchitectureExtras` (everything), `ReducersExtras` (8 reducer modules), `DependenciesExtras` (8 dependency modules)
  - **Standalone Dependencies**: `AppInfo`, `AudioPlayer`, `DeviceInfo`, `LaunchAtLogin`, `LoggerClient`, `OpenSettings`, `OpenURL`, `ShellClient`
  - **Standalone Reducers**: `Analytics`, `AppStoreOverlay`, `Filter`, `FormValidation`, `Haptics`, `Printers`, `ScreenAwake`, `ScreenBrightness`
- **TCA Version**: 1.23.1+ (< 2.0.0)
- **Swift Version**: 6.0+
- **Platforms**: iOS 16+, macOS 15+, tvOS 16+, watchOS 9+
<!-- END AUTO-MANAGED -->

## Architecture
<!-- AUTO-MANAGED: architecture -->
```
Sources/
├── ComposableArchitectureExtras/  # Main umbrella (@_exported import ReducersExtras + DependenciesExtras)
│   └── Resources/
│       └── PrivacyInfo.xcprivacy  # Privacy manifest (DiskSpace + FileTimestamp + SystemBootTime API declarations)
│
├── Reducers/                      # Grouping directory (NOT a target)
│   ├── ReducersExtras/            # Internal umbrella for reducer modules
│   │   └── ReducersExtras.swift   # @_exported imports all 8 reducer modules
│   │
│   ├── AppStoreOverlay/          # State-driven App Store overlay (iOS only, @Presents/ifLet pattern)
│   │   ├── Reducer/             # AppStoreOverlayReducer (State + empty Action)
│   │   ├── View/                # AppStoreOverlayModifier (SwiftUI .appStoreOverlay bridge)
│   │   └── Example/             # Example reducer + view
│   │
│   ├── Analytics/               # Event tracking with declarative result builder syntax
│   │   ├── Dependency/          # AnalyticsClient, AnyAnalyticsClient (type-erased wrapper)
│   │   ├── Reducer/             # AnalyticsReducer, OnChangeAnalyticsReducer
│   │   └── ResultBuilder/       # AnalyticsEventBuilder for declarative event mapping
│   │
│   ├── Filter/                  # Conditional reducer execution based on predicates
│   │   └── Reducer/
│   │       └── FilterReducer.swift
│   │
│   ├── FormValidation/          # Declarative form validation with automatic error management
│   │   ├── FieldValidation.swift
│   │   ├── FormValidationReducer.swift
│   │   ├── Extensions/
│   │   ├── ValidatableField/
│   │   └── ValidationRule/
│   │
│   ├── Haptics/                 # Universal haptic feedback across all Apple platforms
│   │   ├── Dependency/          # FeedbackGeneratorClient, HapticFeedback enum
│   │   └── Reducer/             # HapticsReducer (.haptics modifier)
│   │
│   ├── Printers/                # Debug printing with customizable filtering and formatting
│   │   ├── ActionFilter.swift   # Composable filter combinators (.all, .not, .anyOf, .allExcept)
│   │   └── Printers/            # PrettyPrinter, JSONPrinter, Internal/ utilities
│   │
│   ├── ScreenAwake/             # Prevent screen auto-lock during specific states
│   │   ├── Dependency/          # DeviceScreenAwake (platform-specific implementations)
│   │   └── Reducer/             # ScreenAwakeReducer (.screenAwake modifier)
│   │
│   └── ScreenBrightness/        # State-triggered screen brightness control
│       ├── Dependency/          # ScreenBrightnessClient (iOS-only, others no-op)
│       ├── Model/               # BrightnessLevel enum
│       └── Reducer/             # ScreenBrightnessReducer (.screenBrightness modifier)
│
└── Dependencies/                  # Grouping directory (NOT a target)
    ├── DependenciesExtras/        # Internal umbrella for dependency-only modules
    │   └── DependenciesExtras.swift # @_exported imports all 8 dependency modules (ShellClient + LaunchAtLogin conditionally)
    │
    ├── AppInfo/                   # App bundle metadata (version, build, bundle ID)
    │   └── Dependency/            # AppInfoClient (reads from Bundle.main)
    │
    ├── AudioPlayer/               # Cross-platform fire-and-forget audio playback
    │   ├── AudioPlayerClient.swift            # AudioPlayerClient dependency interface
    │   └── AudioPlayerClient+LiveValue.swift  # AVAudioPlayer-based live implementation
    │
    ├── DeviceInfo/                # Device system information (CPU, memory, disk, battery, network, thermal, low power mode, identity, screen, jailbreak, hostname, boot time, macOS serial/model/updates)
    │   ├── Dependency/            # DeviceInfoClient, measurements (CPU, Memory, Disk, Battery, Network)
    │   ├── Jailbreak/             # iOS-only jailbreak detection checks (Filesystem, Sandbox, Dyld, Environment)
    │   ├── Model/                 # DeviceIdentity, ByteCount, Percentage, CPUInfo, MemoryInfo, DiskInfo, BatteryInfo, NetworkInfo, NetworkInterface, DeviceThermalState, ScreenInfo, ScreenRatio, JailbreakStatus, ModelNameInfo, SoftwareUpdateInfo, etc.
    │   └── Screen/                # ScreenMeasurement (DeviceKit on iOS/tvOS/watchOS, NSScreen on macOS)
    │
    ├── LoggerClient/              # Composable logging with console + file destinations
    │   ├── Dependency/            # AppLoggerClient (merge, noop, TestDependencyKey)
    │   ├── Model/                 # LogEntry, LogFormatter protocol, PlainTextFormatter
    │   ├── Console/               # .console() factory (os.Logger backend)
    │   └── FileLogger/            # .fileLogger() factory, FileLogActor (thread-safe I/O + rotation)
    │
    ├── OpenSettings/              # System settings navigation (cross-platform, ~30 macOS panes)
    │   └── Dependency/            # OpenSettingsClient (platform-specific implementations)
    │
    ├── OpenURL/                   # URL opening with in-app browsing (iOS SFSafariVC)
    │   └── Dependency/            # OpenURLClient (external + in-app, excludes watchOS)
    │
    ├── ShellClient/               # macOS shell command execution (swift-subprocess)
    │   └── ShellClient.swift      # ShellClient, ShellResult, DependencyKey
    │
    └── LaunchAtLogin/             # macOS launch-at-login (SMAppService)
        └── LaunchAtLogin.swift    # LaunchAtLoginClient, Toggle, DependencyKey

Tests/
├── AllTests.xctestplan              # 2 umbrella test targets
├── Reducers/
│   └── ReducersExtrasTests/             # All reducer module tests + umbrella verification
│       ├── ReducersExtrasTests.swift    # Umbrella re-export verification
│       ├── AppStoreOverlay/             # Presentation, dismissal, position tests
│       ├── Analytics/                   # Provider tests (Firebase, Amplitude), reducer, builder
│       ├── Filter/                      # Reducer integration tests
│       ├── FormValidation/              # Unit + integration tests for validation
│       ├── Haptics/                     # Platform-specific haptic feedback tests
│       ├── Printers/                    # PrettyPrinter, ActionFilter tests
│       ├── ScreenAwake/                 # Trigger behavior, call sequence tests
│       └── ScreenBrightness/            # Brightness level, reducer trigger tests
└── Dependencies/
    └── DependenciesExtrasTests/         # All dependency module tests + umbrella verification
        ├── DependenciesExtrasTests.swift # Umbrella re-export + withDependencies tests
        ├── AppInfo/                     # Client tests, withDependencies integration tests
        ├── AudioPlayer/                 # Client tests, play/error verification
        ├── DeviceInfo/                  # Client tests, model tests, ByteCount/Percentage tests
        ├── LoggerClient/                # Merge, formatter, file I/O, rotation, convenience methods, DI tests
        ├── OpenSettings/                # Client tests, withDependencies integration tests
        ├── OpenURL/                     # Client tests, recorder pattern, callAsFunction tests
        ├── ShellClient/                 # Shell command execution tests (macOS only)
        └── LaunchAtLogin/               # Launch-at-login client tests (macOS only)
```
<!-- END AUTO-MANAGED -->

## Module Reference
<!-- AUTO-MANAGED: modules -->

### AppInfo
**Purpose**: Testable access to app bundle metadata (version, build number, bundle identifier)

**Key Features**:
- `AppInfoClient`: Dependency client reading from `Bundle.main.infoDictionary`
- Three properties: `appVersion` (CFBundleShortVersionString), `buildNumber` (CFBundleVersion), `bundleIdentifier`
- `.noop` static for previews and tests returning empty/nil defaults

**Usage Pattern**:
```swift
@Dependency(\.appInfo) var appInfo

let version = appInfo.appVersion()
let build = appInfo.buildNumber()
let bundleId = appInfo.bundleIdentifier()
```

### DeviceInfo
**Purpose**: Cross-platform testable access to device system information (CPU, memory, disk, battery, network, thermal state, low power mode, identity with core counts, screen info, jailbreak detection, hostname, boot time, system uptime, macOS serial/model/updates/password/SSID)

**Key Features**:
- `DeviceInfoClient`: Manual struct (no `@DependencyClient` due to `#if` conditional properties)
- One-shot queries: `identity` (async, includes `totalCoreCount`/`activeCoreCount`/`isiOSAppOnMac`), `cpu` (async, 100ms measurement), `memory`, `disk`, `thermalState`, `isLowPowerModeEnabled`
- Cross-platform additions: `hostname` (sync, device name), `bootTime` (sync, kernel boot time via sysctl), `systemUptime` (sync, awake time via ProcessInfo)
- Platform-conditional: `battery` (async, not tvOS), `network` (async, not watchOS), `screen` (async, not visionOS), `jailbreakStatus` (async, iOS only), `identifierForVendor` (iOS/tvOS/watchOS/visionOS)
- macOS-only: `serialNumber` (sync, IOKit), `modelName` (async, `ModelNameInfo` with identifier/marketing name/icon), `softwareUpdates` (sync, `[SoftwareUpdateInfo]`), `passwordExpiryDays` (async, OpenDirectory), `ssid` (async, CoreWLAN)
- `DeviceIdentity` includes `totalCoreCount`, `activeCoreCount`, `isiOSAppOnMac`, and computed `macOSVersionName` (e.g. "Sequoia" for macOS 15)
- `isLowPowerModeEnabled`: sync one-shot read, false on macOS < 12
- Rich value types: `ByteCount` (formatted bytes), `Percentage` (0-1 raw, 0-100 display)
- `ModelNameInfo` (macOS): `modelIdentifier`, `marketingName`, `shortName`, `year`, `iconSymbolName` (SF Symbol)
- `SoftwareUpdateInfo` (macOS): `displayName`, `displayVersion`, `isMajorUpdate`, `productKey`
- `NetworkInfo` extended: `primaryIPAddress`, `interfaces: [NetworkInterface]` with per-interface type/IP/active status
- `ScreenInfo`: resolution (width/height/scale) on all non-visionOS platforms; iOS adds `screenRatio`, `diagonal`, `ppi`, `hasNotch`, `hasDynamicIsland`, `hasRoundedDisplayCorners` via DeviceKit; tvOS adds `screenRatio`; watchOS adds `screenRatio`, `diagonal`, `ppi`
- `JailbreakStatus`: confidence-based result (`.nominal`, `.low`, `.moderate`, `.high`) from filesystem, sandbox, dyld, and environment checks
- macOS battery includes extended IOKit properties (cycleCount, temperature, maxCapacity, adapterName)
- `.noop` static for previews and tests

**Usage Pattern**:
```swift
@Dependency(\.deviceInfo) var deviceInfo

let identity = await deviceInfo.identity()
let cpu = await deviceInfo.cpu()
let memory = deviceInfo.memory()
let disk = deviceInfo.disk()
let thermal = deviceInfo.thermalState()
let lowPower = deviceInfo.isLowPowerModeEnabled()

// Cross-platform additions
let host = deviceInfo.hostname()
let boot = deviceInfo.bootTime()
let uptime = deviceInfo.systemUptime()

#if !os(tvOS)
let battery = await deviceInfo.battery()
#endif

#if !os(watchOS)
let network = await deviceInfo.network()
#endif

#if !os(visionOS)
let screen = await deviceInfo.screen()
#endif

#if os(iOS)
let jailbreak = await deviceInfo.jailbreakStatus()
#endif

#if os(iOS) || os(tvOS) || os(visionOS) || os(watchOS)
let vendorId = deviceInfo.identifierForVendor()
#endif

#if os(macOS)
let serial = deviceInfo.serialNumber()
let model = await deviceInfo.modelName()
let updates = deviceInfo.softwareUpdates()
let passwordDays = await deviceInfo.passwordExpiryDays()
let wifiName = await deviceInfo.ssid()
#endif
```

### OpenSettings
**Purpose**: Cross-platform system settings navigation with testable dependency

**Key Features**:
- `OpenSettingsClient`: Dependency client with platform-specific `SettingsType` enum
- Platform-conditional cases: `.general` (iOS, macOS, tvOS, visionOS), `.notifications` (iOS, macOS, visionOS)
- macOS: ~30 panes including `.about`, `.network`, `.wifi`, `.bluetooth`, `.sound`, `.displays`, `.storage`, `.softwareUpdate`, `.accessibility`, `.security`, `.privacy(PrivacyPane)`, `.keyboard`, `.trackpad`, `.mouse`, `.printers`, `.battery`, `.dateAndTime`, `.sharing`, `.users`, `.spotlight`, `.siri`, `.desktopAndDock`, `.wallpaper`, `.screenSaver`, `.passwords`, `.appleID`, `.familySharing`, `.screenTime`, `.focusModes`, `.appearance`
- macOS Privacy sub-panes: `.privacy(.location)`, `.privacy(.camera)`, `.privacy(.microphone)`, `.privacy(.photos)`, `.privacy(.contacts)`, `.privacy(.calendars)`, `.privacy(.reminders)`, `.privacy(.fullDiskAccess)`, `.privacy(.accessibility)`, `.privacy(.inputMonitoring)`, `.privacy(.screenRecording)`, `.privacy(.automation)`, `.privacy(.developerTools)`, `.privacy(.analytics)`
- All macOS URLs use `x-apple.systempreferences:` scheme
- iOS/visionOS: `UIApplication.openSettingsURLString`, tvOS: same
- Not available on watchOS (no API exists, module compiles empty)
- `.noop` static for previews and tests

**Usage Pattern**:
```swift
@Dependency(\.openSettings) var openSettings

await openSettings.open(.general)

#if os(iOS) || os(macOS) || os(visionOS)
await openSettings.open(.notifications)
#endif

#if os(macOS)
await openSettings.open(.softwareUpdate)
await openSettings.open(.privacy(.fullDiskAccess))
#endif
```

### OpenURL
**Purpose**: Cross-platform URL opening with in-app browsing via SFSafariViewController (iOS)

**Key Features**:
- `OpenURLClient`: Dependency client with `open` (all platforms) and `openInApp` (iOS only)
- `callAsFunction` ergonomics: `await openURL(url)` and `await openURL(url, prefersInApp: true)`
- iOS: SFSafariViewController via topmost view controller lookup
- macOS: `NSWorkspace.shared.open`, tvOS/visionOS: `UIApplication.shared.open`
- Not available on watchOS (no meaningful URL opening capability)
- Key path: `\.customOpenURL` (avoids shadowing TCA's built-in `\.openURL`)

**Usage Pattern**:
```swift
@Dependency(\.customOpenURL) var openURL

await openURL(URL(string: "https://example.com")!)

#if os(iOS)
await openURL(URL(string: "https://example.com")!, prefersInApp: true)
#endif
```

### ShellClient
**Purpose**: macOS-only shell command execution via swift-subprocess

**Key Features**:
- `ShellClient`: Dependency client wrapping `Subprocess.run()` for `/bin/zsh -c` execution
- `ShellResult`: Result type with `stdout`, `stderr`, `exitCode`, and `succeeded` computed property
- All source wrapped in `#if os(macOS)` — compiles to empty module on other platforms
- `.noop` returns empty successful results

**Usage Pattern**:
```swift
@Dependency(\.shellClient) var shell

let result = try await shell.run("sw_vers -productVersion")
if result.succeeded {
  print(result.stdout) // "15.4"
}
```

### LaunchAtLogin
**Purpose**: macOS-only launch-at-login management via SMAppService

**Key Features**:
- `LaunchAtLoginClient`: Dependency client with `isEnabled()`, `setEnabled(_:)`, `wasLaunchedAtLogin()`
- `LaunchAtLoginClient.Toggle`: Convenience SwiftUI toggle view with `LocalizedStringKey` and `@ViewBuilder` label overloads
- Based on [sindresorhus/LaunchAtLogin-Modern](https://github.com/sindresorhus/LaunchAtLogin-Modern) pattern with error logging via `os.Logger`
- All source wrapped in `#if os(macOS) || targetEnvironment(macCatalyst)`
- `.noop` reports launch-at-login as disabled

**Usage Pattern**:
```swift
@Dependency(\.launchAtLogin) var launchAtLogin

let enabled = launchAtLogin.isEnabled()
try launchAtLogin.setEnabled(true)

// SwiftUI:
LaunchAtLoginClient.Toggle()
LaunchAtLoginClient.Toggle("Open at Login")
LaunchAtLoginClient.Toggle { Text("Launch at login") }
```

### LoggerClient
**Purpose**: Composable logging dependency with console and file destinations

**Key Features**:
- `AppLoggerClient`: Manual struct (no `@DependencyClient`) with sync `log` closure
- `merge()` composition: fan-out to all destinations (matches AnalyticsClient pattern)
- Built-in destinations: `.console()` (os.Logger), `.fileLogger()` (actor-based with rotation), `.noop()`
- `LogFormatter` protocol with `PlainTextFormatter` default (pipe-separated structured output)
- `FileLogActor`: Thread-safe file I/O with size-based rotation (configurable maxFileSize, maxFiles)
- File logger defaults: `Library/Caches/Logs/`, 5MB max, 3 files
- `TestDependencyKey` only (no `liveValue`) — `unimplemented()` warning if unconfigured
- 5 convenience methods with `#file/#function/#line` source location capture
- Custom destinations via `AppLoggerClient.init(log:)`

**Usage Pattern**:
```swift
// Setup (required):
prepareDependencies {
  $0.loggerClient = .merge(
    .console(),
    .fileLogger()
  )
}

// Usage:
@Dependency(\.loggerClient) var logger

logger.info("User logged in")
logger.error("Network request failed")
logger.debug("Cache state: \(keys)")
```

### AppStoreOverlay
**Purpose**: State-driven App Store overlay presentation (iOS only)

**Key Features**:
- `AppStoreOverlayReducer`: Minimal reducer with `State` (appIdentifier + position) and empty `Action`
- Uses `@Presents`/`ifLet` pattern matching TCA's alert/confirmationDialog conventions
- View modifier bridges to SwiftUI's `.appStoreOverlay(isPresented:configuration:)`
- Present by setting state to non-nil, dismiss by nilling or user swipe

**Usage Pattern**:
```swift
// Reducer:
@Presents var overlay: AppStoreOverlayReducer.State?
// ...
state.overlay = .init(appIdentifier: "1511409657")
// ...
.ifLet(\.$overlay, action: \.overlay) { AppStoreOverlayReducer() }

// View:
.appStoreOverlay($store.scope(state: \.overlay, action: \.overlay))
```

### Analytics
**Purpose**: Provider-agnostic event tracking with declarative result builder syntax

**Key Features**:
- Two reducer strategies: action-based (`AnalyticsReducer`) and state-change tracking (`OnChangeAnalyticsReducer`)
- Result builder for declarative event generation with loops and conditionals
- Multi-provider support via `merge()` and type-erased `AnyAnalyticsClient`
- Built-in providers: `.consoleLogger()`, `.noop()`

**Usage Pattern**:
```swift
AnalyticsReducerOf<Self, AppEvent> { state, action in
  switch action {
  case .viewAppeared: .screenViewed(name: "Home")
  case .checkout:
    AppEvent.buttonClicked(id: "checkout")
    AppEvent.purchase(productId: state.id)
  }
}
```

### Filter
**Purpose**: Conditional reducer execution based on state/action predicates

**Usage Pattern**:
```swift
Reduce { state, action in ... }
  .filter { state, action in state.isFeatureEnabled }
```

### FormValidation
**Purpose**: Declarative form validation with automatic error state management

**Key Features**:
- `FieldValidation`: Coordinates validation for fields with rules
- `FormValidationReducer`: TCA integration with binding-triggered validation
- `ValidatableField<T>`: Optional wrapper combining value + error state
- Built-in rules: `.nonEmpty()`, `.length(min:)`, `.greaterOrEqual()`, `.isEqual()`, `.nonOptional()`

**Usage Pattern**:
```swift
FormValidationReducer(
  submitAction: \.submit,
  onFormValidatedAction: .success,
  validations: [
    FieldValidation(field: \.email, errorState: \.emailError, rules: [.nonEmpty(fieldName: "Email")])
  ]
)
```

### Haptics
**Purpose**: State-triggered haptic feedback across all Apple platforms

**Platform Support**:
- iOS: 9 feedback types (success, warning, error, 5 impact styles, selection)
- macOS: 3 types (alignment, levelChange, generic)
- watchOS: 9 types (notification, directions, etc.)
- tvOS: no-op

**Usage Pattern**:
```swift
Reduce { state, action in ... }
  .haptics(.selection, triggerOnChangeOf: \.selectedTab)
  .haptics(.impactMedium(), triggerOnChangeOf: \.count, isEnabled: \.isHapticsEnabled)
```

### Printers
**Purpose**: Debug printing with customizable action filtering and formatted output

**Key Features**:
- `PrettyPrinter`: Box-drawing console output with diff visualization
- `JSONPrinter`: Single-line JSON for log aggregation
- `ActionFilter`: Composable combinators (`.all`, `.not()`, `.anyOf()`, `.allExcept()`)
- Debouncing support to prevent console spam

**Usage Pattern**:
```swift
Reduce { state, action in ... }
  ._printChanges(.prettyConsole(
    allowedActions: .allExcept(.init { if case .binding = $0 { true } else { false } }),
    showTimestamp: true
  ))
```

### ScreenAwake
**Purpose**: Prevent device screen auto-locking during specific app states

**Platform Implementations**:
- iOS/tvOS: `UIApplication.shared.isIdleTimerDisabled`
- macOS: `IOPMAssertionCreateWithName` (IOKit power assertions)
- watchOS: no-op (not supported)

**Usage Pattern**:
```swift
Reduce { state, action in ... }
  .screenAwake(when: \.isPlaying)
```

### ScreenBrightness
**Purpose**: State-triggered screen brightness control with automatic restoration

**Platform Support**:
- iOS: Full support via `UIScreen.main.brightness`
- macOS/watchOS/tvOS: no-op (no public APIs exist)

**Key Features**:
- `BrightnessLevel`: Preset levels (`.low`, `.medium`, `.high`, `.max`) and `.custom(Double)`
- `.automatic`: Restores original brightness captured before first change
- Smart single-shot restoration pattern

**Usage Pattern**:
```swift
Reduce { state, action in ... }
  .screenBrightness(level: \.brightnessLevel)
```
<!-- END AUTO-MANAGED -->

## Testing Patterns
<!-- AUTO-MANAGED: patterns -->

### Test Organization
- **2 umbrella test targets** in `AllTests.xctestplan` (ReducersExtrasTests, DependenciesExtrasTests)
- **Unit tests**: Direct validation testing without TCA overhead (e.g., `FieldValidation/`)
- **Integration tests**: `TestStore`-based reducer testing with `@MainActor` isolation
- **Nested `@Suite`** attributes for hierarchical test grouping
- Each module has `Reducer/TestReducer.swift` fixture
- **macOS-only tests**: ShellClient, LaunchAtLogin, and DeviceInfo extended tests use `#if os(macOS)` guards
- **New DeviceInfo test files**: `ModelNameInfoTests`, `SoftwareUpdateInfoTests`, `NetworkInterfaceTests`, `DeviceIdentityExtendedTests`, `DeviceInfoExtendedTests`

### TestStore Patterns
```swift
// Standard setup
let store = TestStore(initialState: State(), reducer: Reducer.init)

// With dependency injection
let store = TestStore(initialState: State()) {
  Reducer()
} withDependencies: {
  $0.feedbackGenerator = collector.client
}

// State mutation assertions
await store.send(.action) {
  $0.field = value
  $0.error = "Expected error"
}

// Effect reception
await store.receive(\.formValidationSucceed)
```

### Mock/Recording Patterns
Thread-safe collectors for dependency verification:
- `EventCollector` (Analytics): Tracks analytics events
- `FeedbackCollector` (Haptics): Records generated/prepared haptic feedback
- `RecordingDeviceScreenAwake` (ScreenAwake): Tracks enable/disable calls
- `RecordingScreenBrightnessClient` (ScreenBrightness): Tracks brightness level changes
- `OpenURLRecorder` (OpenURL): Records opened URLs and in-app URLs

**Pattern**:
```swift
@MainActor
final class RecordingDependency: Sendable {
  enum Call: Equatable, Sendable { case enable, case disable }
  nonisolated(unsafe) var calls: [Call] = []

  var dependency: DependencyType { ... }
}
```

### Platform-Specific Testing
```swift
#if os(iOS)
  #expect(collector.feedbacks == [.selection])
#elseif os(macOS)
  #expect(collector.feedbacks == [.alignment])
#elseif os(watchOS)
  #expect(collector.feedbacks == [.watchClick])
#endif
```

### FormValidation-Specific Testing
- **FieldValidation tests**: Direct `validate(state:)` testing
- **Validation rules**: Boundary tests (below, equal, above threshold)
- **Submit flow**: Invalid → partial → fully valid progression
- **Test helpers**: `.alwaysTrue()` and `.alwaysFalse(withID:)` rules
<!-- END AUTO-MANAGED -->

## Conventions
<!-- AUTO-MANAGED: conventions -->

### Comments
- **No `// MARK:` or explanatory comments** unless the code cannot explain itself
- Code structure (extensions, `#if os(...)` blocks) should be self-documenting
- No trailing comments on `#endif` unless nesting makes it genuinely ambiguous

### Imports
- `import ComposableArchitecture` for TCA integration tests
- `import Testing` for Swift Testing framework
- `@testable import ModuleName` for test fixtures only

### Test Naming
- Backtick natural language: `` `binding with value below 18 shows error` ``
- Format: `` `action with condition shows/clears expected result` ``

### Reducer Modifier Pattern
All modules provide chainable reducer modifiers:
```swift
extension Reducer {
  public func moduleName(...) -> some ReducerOf<Self> {
    _InternalReducer(base: self, ...)
  }
}
```

### Dependency Pattern
```swift
@DependencyClient
public struct Client: Sendable {
  public var method: @Sendable () async -> Void
}

extension Client: DependencyKey {
  public static var liveValue: Client { ... }
}

extension DependencyValues {
  public var client: Client { ... }
}
```

### Error Messages (FormValidation)
- Format: "[Field] should be [condition]" or custom message
- Examples: "Email should not be empty", "Age should be greater or equal to 18"
<!-- END AUTO-MANAGED -->

## TCA Integration Conventions
<!-- AUTO-MANAGED: tca-conventions -->

### Reducer Structure
- Use `@Reducer` macro for all reducer definitions
- Implement `var body: some ReducerOf<Self>` for composition
- Order: `BindingReducer()` → feature logic → utility reducers (filter, haptics, etc.)

### State and Actions
- Mark state with `@ObservableState` and `Equatable`
- Use `BindableAction` protocol for form-like features
- Leverage `CaseKeyPath` for action routing

### Effects
- `.none`: Pure state changes
- `.run { }`: Async side effects with dependency capture
- `.send(action)`: Immediate action emission
- Capture dependencies: `return .run { [dependency] _ in ... }`

### Performance
- Mark public API with `@inlinable` for composition performance
- Use `@usableFromInline` for internal helpers crossed module boundaries
<!-- END AUTO-MANAGED -->

## Dependencies
<!-- AUTO-MANAGED: dependencies -->
- **ComposableArchitecture** (v1.23.1+): Core TCA framework
- **DeviceKit** (v5.7.0+): Device hardware metadata for ScreenInfo (iOS/tvOS/watchOS only, conditional dependency)
- **swift-subprocess** (v0.1.0+): Shell command execution for ShellClient module (macOS, swiftlang/swift-subprocess)
- **Dependencies** / **DependenciesMacros**: Dependency injection (via TCA)
- **XCTestDynamicOverlay**: Test doubles (via TCA)
- **CustomDump**: Diff visualization in Printers module (via TCA)
- **Swift Testing**: Native Swift testing framework
<!-- END AUTO-MANAGED -->

## CI Configuration
<!-- AUTO-MANAGED: ci-config -->
GitHub Actions workflow at `.github/workflows/ci.yml`:

- **Runner**: `macos-26` (Xcode 26)
- **Jobs**: Single `ci` job per platform (build + test sequential steps sharing DerivedData)
- **Platforms**: iOS, macOS, tvOS, watchOS
- **Simulators**: iPhone 17, Apple TV 4K (3rd generation), Apple Watch Series 11 (46mm)
- **Actions**: `actions/checkout@v6`, `actions/cache@v5`
- **Schemes**: `ComposableArchitectureExtras` (Build Library step) and `AllTests` (Run Tests step, references `AllTests.xctestplan` with 2 umbrella test targets)
- **DerivedData**: Project-relative `.derivedData` via `-derivedDataPath`, shared between build and test steps
- **Cache key**: `deriveddata-{platform}-{hash(Package.swift, Package.resolved)}` with platform-only restore-key fallback
- **Xcode setting**: `IgnoreFileSystemDeviceInodeChanges` prevents cache invalidation from inode changes

### Critical CI Patterns
- **Macro validation**: Use `-skipMacroValidation` xcodebuild flag
- **Failure detection**: Use `set -o pipefail` before xcodebuild piped to xcpretty
- **NEVER use `|| true`**: This masks all failures and CI will always pass
- **DerivedData sharing**: Both build and test steps use `-derivedDataPath .derivedData` so test reuses compiled artifacts
<!-- END AUTO-MANAGED -->

## Privacy Manifest
<!-- AUTO-MANAGED: privacy-manifest -->
**File**: `Sources/ComposableArchitectureExtras/Resources/PrivacyInfo.xcprivacy`

Bundled via `resources: [.process("Resources")]` on the `ComposableArchitectureExtras` umbrella target.

### Declared API Categories
| Category | Reason | Source |
|----------|--------|--------|
| `NSPrivacyAccessedAPICategoryDiskSpace` | `85F4.1` (display to user) | `DiskMeasurement.swift` — `URLResourceKey.volumeTotalCapacityKey`, `.volumeAvailableCapacityKey`, `.volumeAvailableCapacityForImportantUsageKey` |
| `NSPrivacyAccessedAPICategoryFileTimestamp` | `C617.1` (app functionality) | `FilesystemCheck.swift` (iOS jailbreak detection) — `FileManager.attributesOfItem(atPath:)` calls `stat()` |
| `NSPrivacyAccessedAPICategorySystemBootTime` | `35F9.1` (measure elapsed time) | `DeviceInfoClient.bootTime()` — `sysctl` with `CTL_KERN` + `KERN_BOOTTIME` to read kernel boot time |

### Not Declared (not used)
- UserDefaults, ActiveKeyboards — none of these APIs are used by this package

### Consumer Note
Apps using the Analytics module with real providers must declare their own `NSPrivacyCollectedDataTypes` in their app's privacy manifest.
<!-- END AUTO-MANAGED -->
