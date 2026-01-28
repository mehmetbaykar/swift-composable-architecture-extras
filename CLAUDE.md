# CLAUDE.md

## Project Description
<!-- AUTO-MANAGED: project-description -->
Swift Composable Architecture Extras - A Swift Package providing form validation utilities for TCA applications. Includes `FormValidation` module with declarative field validation rules and reducer integration.
<!-- END AUTO-MANAGED -->

## Build Commands
<!-- AUTO-MANAGED: build-commands -->
- Build: `swift build`
- Test: `swift test`
- Clean: `swift package clean`
<!-- END AUTO-MANAGED -->

## Architecture
<!-- AUTO-MANAGED: architecture -->
```
Sources/
├── FormValidation/          # Core form validation module
│   ├── Export.swift
│   ├── FieldValidation.swift
│   ├── FormValidationReducer.swift
│   ├── Extensions/
│   ├── ValidatableField/
│   └── ValidationRule/
└── Filter/                  # Additional utilities

Tests/
└── FormValidationTests/
    ├── FieldValidation/
    │   └── FieldValidationTests.swift    # Unit tests for FieldValidation core logic
    ├── Reducer/
    │   ├── TestReducer.swift             # Test fixture reducer
    │   ├── IntFieldTests.swift           # IntField validation tests
    │   ├── StringFieldTests.swift        # StringField validation tests
    │   └── SubmitFlowTests.swift         # Form submission flow tests
    └── ValidationRule/
```
<!-- END AUTO-MANAGED -->

## Testing Patterns
<!-- AUTO-MANAGED: patterns -->
### Test Organization
- **FieldValidation tests**: Unit tests for `FieldValidation` struct validation logic without TCA integration
- **Reducer tests**: Integration tests using `TestStore` with `FormValidationReducer` and TCA bindings
- Tests organized by validation rule type using `@Suite` attributes
- Each suite targets a specific field type (IntField, StringField) or flow (SubmitFlow)
- Nested suites group related validation rule tests

### Test Structure
- **Unit tests** (`FieldValidation/`): Direct validation testing with mutable state and `validate()` calls
- **Integration tests** (`Reducer/`): TCA integration testing marked `@MainActor`
- Use `TestStore` with initial state and reducer for integration tests
- Test state mutations using trailing closure syntax: `await store.send(.action) { $0.field = value }`
- Verify validation errors set on binding changes
- Verify error clearing when valid values provided

### FieldValidation Unit Testing
- Tests `FieldValidation.validate(state:)` directly without reducer overhead
- Successful validation sets error to nil and returns true
- Failed validation sets first failing rule error and returns false
- Uses custom test helpers: `.alwaysTrue()` and `.alwaysFalse(withID:)`

### Validation Rule Testing
- **GreaterOrEqualRule**: Tests boundary conditions (below, equal, above threshold)
- **LengthRule**: Tests minimum length validation with string boundaries
- **IsEqualRule**: Tests exact string matching
- **ErrorTransitions**: Tests sequential validation rule application

### Submit Flow Testing
- Tests form submission with invalid fields (shows all errors, no effect)
- Tests partial validation (shows remaining errors)
- Tests successful validation (clears errors, emits success action with `await store.receive(\.formValidationSucceed)`)

### Common Test Fixture
- `TestReducer` provides consistent test setup with:
  - `stringField` and `intField` state
  - `stringFieldError` and `intFieldError` optional error strings
  - `FormValidationReducer` integration with multiple `FieldValidation` rules
  - Success action: `.formValidationSucceed`
<!-- END AUTO-MANAGED -->

## Conventions
<!-- AUTO-MANAGED: conventions -->
### Imports
- `import FormValidation` for unit tests (FieldValidation tests)
- `import ComposableArchitecture` for TCA integration tests (Reducer tests)
- `import Testing` for Swift Testing framework
- `@testable import FormValidation` for test fixtures only (TestReducer)

### Test Naming
- Test function names use backticks for natural language descriptions
- Format: `` `action with condition shows/clears expected result` ``
- Examples: `` `binding with value below 18 shows error` ``, `` `submit with all valid fields clears errors and emits success` ``

### Error Messages
- Error messages specific to validation rule and field
- Format: "[Field] should be [condition]" or "[Rule] error"
- Examples: "Intfield should be greater or equal to 18", "Min length error"
<!-- END AUTO-MANAGED -->

## Dependencies
<!-- AUTO-MANAGED: dependencies -->
- **ComposableArchitecture** (v1.23.1+): Core TCA framework for reducer composition and state management
- **Swift Testing**: Native Swift testing framework for test organization and execution
<!-- END AUTO-MANAGED -->
