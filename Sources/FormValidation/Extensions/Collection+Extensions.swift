import Foundation

extension Collection {
  /// Triggers the validation of all ``ValidationRule/ValidationRule``.
  public func validate<Value>(_ value: Value) -> String? where Element == ValidationRule<Value> {
    first(where: { $0.validate(value) == false })
      .map(\.errorMessage)
  }
}
