import Foundation

public struct FieldValidation<State> {
  let binding: PartialKeyPath<State>

  private let _validate: (inout State) -> Bool

  private init<FieldType>(
    binding: PartialKeyPath<State>,
    field: KeyPath<State, FieldType>,
    errorState: WritableKeyPath<State, String?>,
    rules: [ValidationRule<FieldType>]
  ) {
    self.binding = binding

    // Extract field name and enrich rules that contain the placeholder
    let fieldName = extractFieldName(from: field)
    let enrichedRules = rules.map { rule in
      rule.withFieldName(fieldName)
    }

    self._validate = { state in
      let value = state[keyPath: field]
      let validationError = enrichedRules.validate(value)

      state[keyPath: errorState] = validationError

      return validationError == nil
    }
  }

  @discardableResult
  public func validate(state: inout State) -> Bool {
    _validate(&state)
  }
}

extension FieldValidation {
  public init<Value>(
    field: WritableKeyPath<State, Value>,
    errorState: WritableKeyPath<State, String?>,
    rules: [ValidationRule<Value>]
  ) {
    self.init(
      binding: field,
      field: field,
      errorState: errorState,
      rules: rules
    )
  }

  public init<Value>(
    field: WritableKeyPath<State, ValidatableField<Value>>,
    rules: [ValidationRule<Value>]
  ) {
    self.init(
      binding: field,
      field: field.appending(path: \.value),
      errorState: field.appending(path: \.errorText),
      rules: rules
    )
  }
}
