import Foundation

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
}
