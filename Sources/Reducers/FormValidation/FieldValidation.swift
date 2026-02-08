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

    let enrichedRules = Self.enrichRules(rules, from: binding)

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

extension FieldValidation {
  private static func enrichRules<FieldType>(
    _ rules: [ValidationRule<FieldType>],
    from keyPath: PartialKeyPath<State>
  ) -> [ValidationRule<FieldType>] {
    let fieldName = Self.extractFieldName(from: keyPath)
    return rules.map { rule in
      var enriched = rule
      enriched.enrichFieldName(fieldName)
      return enriched
    }
  }

  private static func extractFieldName(from keyPath: PartialKeyPath<State>) -> String {
    let description = String(describing: keyPath)
    guard let lastDotIndex = description.lastIndex(of: ".") else {
      return description
    }
    return String(description[description.index(after: lastDotIndex)...])
  }
}
