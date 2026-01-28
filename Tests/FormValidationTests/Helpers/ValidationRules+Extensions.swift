import Foundation

@testable import FormValidation

extension ValidationRule where Value == String {
  static func alwaysTrue() -> Self {
    ValidationRule(error: "Should never show") { _ in true }
  }

  static func alwaysFalse(withID id: String) -> Self {
    ValidationRule(error: "Test validation \(id)") { _ in false }
  }
}
