# CLAUDE.md

## Project Description
<!-- AUTO-MANAGED: project-description -->
Swift Composable Architecture Extras - A Swift Package providing production-ready reducer patterns, dependencies, and utilities for TCA applications. Organized into 2 internal umbrellas: **ReducersExtras** (7 reducer modules) and **DependenciesExtras** (dependency-only modules). Includes 8 modules: **Analytics** (event tracking), **AppInfo** (bundle metadata), **Filter** (conditional execution), **FormValidation** (declarative validation), **Haptics** (universal haptic feedback), **Printers** (debug output), **ScreenAwake** (display management), and **ScreenBrightness** (brightness control).
<!-- END AUTO-MANAGED -->

## Build Commands
<!-- AUTO-MANAGED: build-commands -->
- Build: `swift build`
- Test: `swift test`
- Clean: `swift package clean`
<!-- END AUTO-MANAGED -->

## Package Configuration
<!-- AUTO-MANAGED: package-config -->
- **Product**: `ComposableArchitectureExtras` (single library exporting all 8 modules)
- **Internal Umbrellas**: `ReducersExtras` (7 reducer modules), `DependenciesExtras` (dependency-only modules)
- **TCA Version**: 1.23.1+ (< 2.0.0)
- **Swift Version**: 6.0+
- **Platforms**: iOS 13+, macOS 10.15+, tvOS 13+, watchOS 6+
<!-- END AUTO-MANAGED -->

## Architecture
<!-- AUTO-MANAGED: architecture -->
```
Sources/
├── ComposableArchitectureExtras/  # Main umbrella (@_exported import ReducersExtras + DependenciesExtras)
│
├── Reducers/                      # Grouping directory (NOT a target)
│   ├── ReducersExtras/            # Internal umbrella for reducer modules
│   │   └── ReducersExtras.swift   # @_exported imports all 7 reducer modules
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
    │   └── DependenciesExtras.swift # @_exported imports AppInfo
    │
    └── AppInfo/                   # App bundle metadata (version, build, bundle ID)
        └── Dependency/            # AppInfoClient (reads from Bundle.main)

Tests/
├── AllTests.xctestplan              # 2 umbrella test targets
├── Reducers/
│   └── ReducersExtrasTests/             # All reducer module tests + umbrella verification
│       ├── ReducersExtrasTests.swift    # Umbrella re-export verification
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
        └── AppInfo/                     # Client tests, withDependencies integration tests
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
- **Dependencies** / **DependenciesMacros**: Dependency injection (via TCA)
- **XCTestDynamicOverlay**: Test doubles (via TCA)
- **CustomDump**: Diff visualization in Printers module (via TCA)
- **Swift Testing**: Native Swift testing framework
<!-- END AUTO-MANAGED -->

## CI Configuration
<!-- AUTO-MANAGED: ci-config -->
GitHub Actions workflow at `.github/workflows/ci.yml`:

- **Runner**: `macos-26` (Xcode 26)
- **Jobs**: Separate `build` and `test` jobs
- **Platforms**: iOS, macOS, tvOS, watchOS
- **Simulators**: iPhone 17, Apple TV 4K (3rd generation), Apple Watch Series 11 (46mm)
- **Actions**: `actions/checkout@v6`, `actions/cache@v5`
- **Schemes**: `ComposableArchitectureExtras` (build job, library-only) and `AllTests` (test job, references `AllTests.xctestplan` with 2 umbrella test targets)

### Critical CI Patterns
- **Macro validation**: Use `-skipMacroValidation` xcodebuild flag
- **Failure detection**: Use `set -o pipefail` before xcodebuild piped to xcpretty
- **NEVER use `|| true`**: This masks all failures and CI will always pass
<!-- END AUTO-MANAGED -->
