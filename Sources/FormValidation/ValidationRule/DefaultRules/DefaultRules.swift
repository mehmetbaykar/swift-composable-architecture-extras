import Foundation

extension ValidationRule {

  // MARK: - Auto Field Name Rules
  // These rules use the `fieldNamePlaceholder` and will have the field name
  // automatically injected by `FieldValidation` based on the keypath.

  /// Validates that a collection is not empty.
  ///
  /// The field name will be automatically derived from the keypath used in `FieldValidation`.
  ///
  /// Example:
  /// ```swift
  /// FieldValidation(
  ///   field: \.email,
  ///   errorState: \.emailError,
  ///   rules: [.nonEmpty()]  // Error: "Email should not be empty"
  /// )
  /// ```
  public static func nonEmpty() -> Self where Value: Collection {
    .init(
      error: "\(fieldNamePlaceholder) should not be empty",
      validation: { !$0.isEmpty }
    )
  }

  /// Validates that a comparable value is greater than or equal to a threshold.
  ///
  /// The field name will be automatically derived from the keypath used in `FieldValidation`.
  ///
  /// Example:
  /// ```swift
  /// FieldValidation(
  ///   field: \.age,
  ///   errorState: \.ageError,
  ///   rules: [.greaterOrEqual(to: 18)]  // Error: "Age should be greater or equal to 18"
  /// )
  /// ```
  public static func greaterOrEqual(to value: Value) -> Self
  where Value: Comparable {
    .init(
      error: "\(fieldNamePlaceholder) should be greater or equal to \(value)",
      validation: { $0 >= value }
    )
  }

  /// Validates that a value equals the expected value.
  ///
  /// The field name will be automatically derived from the keypath used in `FieldValidation`.
  ///
  /// Example:
  /// ```swift
  /// FieldValidation(
  ///   field: \.country,
  ///   errorState: \.countryError,
  ///   rules: [.isEqual(to: "US")]  // Error: "Country should be US"
  /// )
  /// ```
  public static func isEqual(to value: Value) -> Self where Value: Equatable {
    .init(
      error: "\(fieldNamePlaceholder) should be \(value)",
      validation: { $0 == value }
    )
  }

  /// Validates that an optional value is not nil.
  ///
  /// The field name will be automatically derived from the keypath used in `FieldValidation`.
  ///
  /// Example:
  /// ```swift
  /// FieldValidation(
  ///   field: \.selectedOption,
  ///   errorState: \.selectedOptionError,
  ///   rules: [.nonOptional()]  // Error: "Selected Option should not be empty"
  /// )
  /// ```
  public static func nonOptional<T>() -> Self where Value == T? {
    .init(
      error: "\(fieldNamePlaceholder) should not be empty",
      validation: { $0 != nil }
    )
  }

  // MARK: - Explicit Field Name Rules
  // These rules require an explicit field name parameter for custom naming.

  /// Validates that a collection is not empty with an explicit field name.
  ///
  /// Use this when you want to specify a custom field name different from the keypath.
  public static func nonEmpty(fieldName: String) -> Self where Value: Collection {
    .init(
      error: "\(fieldName.capitalized) should not be empty",
      validation: { !$0.isEmpty }
    )
  }

  /// Validates minimum length of a collection with a custom error message.
  public static func length(min: UInt, error: String) -> Self where Value: Collection {
    .init(error: error, validation: { $0.count >= min })
  }

  /// Validates that a comparable value is greater than or equal to a threshold with an explicit field name.
  ///
  /// Use this when you want to specify a custom field name different from the keypath.
  public static func greaterOrEqual(to value: Value, fieldName: String) -> Self
  where Value: Comparable {
    .init(
      error: "\(fieldName.capitalized) should be greater or equal to \(value)",
      validation: { $0 >= value }
    )
  }

  /// Validates that a value equals the expected value with an explicit field name.
  ///
  /// Use this when you want to specify a custom field name different from the keypath.
  public static func isEqual(to value: Value, fieldName: String) -> Self where Value: Equatable {
    .isEqual(to: value, errorMessage: "\(fieldName.capitalized) should be \(value)")
  }

  /// Validates that a value equals the expected value with a custom error message.
  public static func isEqual(to value: Value, errorMessage: String) -> Self where Value: Equatable {
    .init(error: errorMessage, validation: { $0 == value })
  }

  /// Validates that an optional value is not nil with a custom error message.
  public static func nonOptional<T>(_ errorMessage: String) -> Self where Value == T? {
    .init(error: errorMessage, validation: { $0 != nil })
  }
}
