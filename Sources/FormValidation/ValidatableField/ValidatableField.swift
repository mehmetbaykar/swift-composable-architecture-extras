import Foundation

public struct ValidatableField<Value> {
  public var value: Value
  public var errorText: String?

  public init(value: Value, errorText: String? = nil) {
    self.value = value
    self.errorText = errorText
  }
}

extension ValidatableField: Equatable where Value: Equatable {}
extension ValidatableField: Sendable where Value: Sendable {}
