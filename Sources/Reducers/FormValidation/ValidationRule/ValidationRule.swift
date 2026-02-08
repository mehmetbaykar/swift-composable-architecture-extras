import Foundation

public struct ValidationRule<Value> {
  private(set) var errorMessage: String
  let validation: (Value) -> Bool

  static var fieldNamePlaceholder: String { "{fieldName}" }

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

  mutating func enrichFieldName(_ fieldName: String) {
    errorMessage = errorMessage.replacingOccurrences(
      of: Self.fieldNamePlaceholder,
      with: fieldName.capitalized
    )
  }
}
