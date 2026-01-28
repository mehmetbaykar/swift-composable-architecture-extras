import Foundation

extension ValidatableField:
  ExpressibleByStringLiteral,
  ExpressibleByExtendedGraphemeClusterLiteral,
  ExpressibleByUnicodeScalarLiteral
where Value == String {
  public init(stringLiteral value: StringLiteralType) {
    self.init(value: value)
  }
}

extension ValidatableField: ExpressibleByIntegerLiteral where Value == Int {
  public init(integerLiteral value: IntegerLiteralType) {
    self.init(value: value)
  }
}

extension ValidatableField: ExpressibleByFloatLiteral where Value == Double {
  public init(floatLiteral value: FloatLiteralType) {
    self.init(value: value)
  }
}

extension ValidatableField: ExpressibleByBooleanLiteral where Value == Bool {
  public init(booleanLiteral value: BooleanLiteralType) {
    self.init(value: value)
  }
}
