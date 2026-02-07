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
          rules: [.nonEmpty(fieldName: "Email")]
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
  rules: [.nonEmpty(fieldName: "Username")]
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
  rules: [.nonEmpty(fieldName: "Username")]
)
```

Supported literal types: `String`, `Int`, `Double`, `Bool`.

## Define Your Rules

### Built-in Rules

#### nonEmpty

Validates that a collection is not empty.

```swift
// Default message: "Username should not be empty"
.nonEmpty(fieldName: "Username")
```

#### length

Validates minimum length of a collection.

```swift
// Custom message required
.length(min: 8, error: "Password must be at least 8 characters")
```

#### greaterOrEqual

Validates that a comparable value meets a minimum threshold.

```swift
// Default message: "Age should be greater or equal to 18"
.greaterOrEqual(to: 18, fieldName: "Age")
```

#### isEqual

Validates exact equality.

```swift
// Default message: "Country should be US"
.isEqual(to: "US", fieldName: "Country")

// Custom message
.isEqual(to: "US", errorMessage: "Only US residents allowed")
```

#### nonOptional

Validates that an optional value is not nil.

```swift
// Custom message required
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
  rules: [.nonEmpty(fieldName: "Email"), .validEmail]
)
```

## Validation Behavior

- **On binding change**: Only the changed field is validated
- **On submit**: All fields are validated
- **Multiple rules**: First failing rule's error is shown

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
            .nonEmpty(fieldName: "Email"),
            .validEmail
          ]
        ),
        FieldValidation(
          field: \.password,
          rules: [
            .nonEmpty(fieldName: "Password"),
            .length(min: 8, error: "Password must be at least 8 characters")
          ]
        ),
        FieldValidation(
          field: \.age,
          rules: [
            .greaterOrEqual(to: 18, fieldName: "Age")
          ]
        ),
        FieldValidation(
          field: \.selectedCountry,
          errorState: \.countryError,
          rules: [
            .nonOptional("Please select a country")
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
