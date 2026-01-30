## FormValidation

A declarative form validation system for TCA that handles field-level validation rules and reducer integration with automatic error state management.

## Quick Start

```swift
import ComposableArchitectureExtras

@Reducer
struct LoginReducer {
  @ObservableState
  struct State: Equatable {
    var email = ""
    var emailError: String?
  }

  enum Action: BindableAction {
    case binding(BindingAction<State>)
    case submitTapped
    case loginSucceeded
  }

  var body: some ReducerOf<Self> {
    BindingReducer()

    FormValidationReducer(
      submitAction: \.submitTapped,
      onFormValidatedAction: .loginSucceeded,
      validations: [
        FieldValidation(
          field: \.email,
          errorState: \.emailError,
          rules: [.nonEmpty()]  // Field name auto-derived: "Email should not be empty"
        )
      ]
    )

    Reduce { state, action in
      // Business logic
    }
  }
}
```

## State Patterns

### Separate Fields Pattern

Store value and error as separate state properties:

```swift
@ObservableState
struct State: Equatable {
  var username = ""
  var usernameError: String?
  var age = 0
  var ageError: String?
}

FieldValidation(
  field: \.username,
  errorState: \.usernameError,
  rules: [.nonEmpty()]  // Auto: "Username should not be empty"
)
```

### ValidatableField Wrapper

Combine value and error in a single wrapper with literal initialization:

```swift
@ObservableState
struct State: Equatable {
  var username: ValidatableField<String> = ""
  var age: ValidatableField<Int> = 0
}

FieldValidation(
  field: \.username,
  rules: [.nonEmpty()]  // Auto: "Username should not be empty"
)
```

Supported literal types: `String`, `Int`, `Double`, `Bool`.

## Define Your Rules

### Built-in Rules

All built-in rules support **automatic field name extraction** from the keypath. The field name is derived from the property name and formatted for display (e.g., `\.userEmail` → "User Email").

#### nonEmpty

Validates that a collection is not empty.

```swift
// Auto field name (recommended): Error derived from keypath
.nonEmpty()  // "Username should not be empty" for \.username

// Explicit field name: Override the auto-derived name
.nonEmpty(fieldName: "Email Address")  // "Email Address should not be empty"
```

#### length

Validates minimum length of a collection.

```swift
// Custom message required (no auto field name)
.length(min: 8, error: "Password must be at least 8 characters")
```

#### greaterOrEqual

Validates that a comparable value meets a minimum threshold.

```swift
// Auto field name: Error derived from keypath
.greaterOrEqual(to: 18)  // "Age should be greater or equal to 18" for \.age

// Explicit field name
.greaterOrEqual(to: 18, fieldName: "Your Age")
```

#### isEqual

Validates exact equality.

```swift
// Auto field name
.isEqual(to: "US")  // "Country should be US" for \.country

// Explicit field name
.isEqual(to: "US", fieldName: "Country")

// Custom message
.isEqual(to: "US", errorMessage: "Only US residents allowed")
```

#### nonOptional

Validates that an optional value is not nil.

```swift
// Auto field name
.nonOptional()  // "Selection should not be empty" for \.selection

// Custom message
.nonOptional("Please select an option")
```

### Custom Rules

Create validation rules for any requirement:

```swift
extension ValidationRule where Value == String {
  static var validEmail: Self {
    .init(
      error: "Please enter a valid email address",
      validation: { value in
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return value.range(of: pattern, options: .regularExpression) != nil
      }
    )
  }
}

// Usage
FieldValidation(
  field: \.email,
  errorState: \.emailError,
  rules: [.nonEmpty(), .validEmail]
)
```

### Custom Rules with Auto Field Name

You can create custom rules that also support automatic field name injection using the `fieldNamePlaceholder` constant:

```swift
extension ValidationRule where Value == String {
  static func matchesPattern(_ pattern: String) -> Self {
    .init(
      error: "\(fieldNamePlaceholder) has an invalid format",
      validation: { value in
        value.range(of: pattern, options: .regularExpression) != nil
      }
    )
  }
}

// Usage - field name will be injected automatically
FieldValidation(
  field: \.postalCode,
  errorState: \.postalCodeError,
  rules: [.matchesPattern(#"^\d{5}$"#)]  // "Postal Code has an invalid format"
)
```

## Validation Behavior

- **On binding change**: Only the changed field is validated
- **On submit**: All fields are validated
- **Multiple rules**: First failing rule's error is shown
- **Auto field name**: The field name is extracted from the keypath and formatted (camelCase → "Title Case")

## Full Example

```swift
import ComposableArchitectureExtras

@Reducer
struct RegistrationReducer {
  @ObservableState
  struct State: Equatable {
    // Separate fields pattern
    var email = ""
    var emailError: String?

    // ValidatableField pattern
    var password: ValidatableField<String> = ""
    var age: ValidatableField<Int> = 0

    var selectedCountry: String?
    var countryError: String?
  }

  enum Action: BindableAction {
    case binding(BindingAction<State>)
    case submitTapped
    case registrationSucceeded
  }

  var body: some ReducerOf<Self> {
    BindingReducer()

    FormValidationReducer(
      submitAction: \.submitTapped,
      onFormValidatedAction: .registrationSucceeded,
      validations: [
        FieldValidation(
          field: \.email,
          errorState: \.emailError,
          rules: [
            .nonEmpty(),  // "Email should not be empty"
            .validEmail
          ]
        ),
        FieldValidation(
          field: \.password,
          rules: [
            .nonEmpty(),  // "Password should not be empty"
            .length(min: 8, error: "Password must be at least 8 characters")
          ]
        ),
        FieldValidation(
          field: \.age,
          rules: [
            .greaterOrEqual(to: 18)  // "Age should be greater or equal to 18"
          ]
        ),
        FieldValidation(
          field: \.selectedCountry,
          errorState: \.countryError,
          rules: [
            .nonOptional()  // "Selected Country should not be empty"
          ]
        )
      ]
    )

    Reduce { state, action in
      switch action {
      case .binding, .submitTapped:
        return .none
      case .registrationSucceeded:
        // Handle successful registration
        return .none
      }
    }
  }
}

extension ValidationRule where Value == String {
  static var validEmail: Self {
    .init(
      error: "Please enter a valid email address",
      validation: { value in
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return value.range(of: pattern, options: .regularExpression) != nil
      }
    )
  }
}
```
