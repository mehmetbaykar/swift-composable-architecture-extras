import Foundation

/// A placeholder constant used in error messages that will be replaced with the actual field name.
///
/// Use this constant when creating validation rules that should have their field name
/// automatically injected by `FieldValidation`.
///
/// Example:
/// ```swift
/// // Create a rule with auto field name:
/// .init(
///   error: "\(fieldNamePlaceholder) should not be empty",
///   validation: { !$0.isEmpty }
/// )
/// // When used with FieldValidation(field: \.email, ...), becomes: "Email should not be empty"
/// ```
public let fieldNamePlaceholder = "{fieldName}"

public struct ValidationRule<Value> {
  let errorMessage: String
  let validation: (Value) -> Bool

  public init(
    error: String,
    validation: @escaping (Value) -> Bool
  ) {
    self.errorMessage = error
    self.validation = validation
  }

  public func validate(_ value: Value) -> Bool {
    validation(value)
  }

  /// Creates a new validation rule with the placeholder replaced by the actual field name.
  ///
  /// This is called automatically by `FieldValidation` when the rule's error message
  /// contains the `fieldNamePlaceholder` constant.
  ///
  /// - Parameter fieldName: The formatted field name to inject into the error message
  /// - Returns: A new `ValidationRule` with the field name substituted in the error message
  public func withFieldName(_ fieldName: String) -> Self {
    ValidationRule(
      error: errorMessage.replacingOccurrences(of: fieldNamePlaceholder, with: fieldName),
      validation: validation
    )
  }
}
