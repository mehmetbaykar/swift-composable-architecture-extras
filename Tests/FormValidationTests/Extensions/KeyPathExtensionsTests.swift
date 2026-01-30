import Testing

@testable import FormValidation

@Suite("KeyPath Extensions")
struct KeyPathExtensionsTests {

  @Suite("extractFieldName")
  struct ExtractFieldNameTests {

    struct TestState {
      var email: String = ""
      var userAge: Int = 0
      var firstName: String = ""
      var someVeryLongFieldName: Bool = false
      var x: Int = 0
      var userID: String = ""
    }

    @Test func `extracts simple field name and capitalizes`() {
      let fieldName = extractFieldName(from: \TestState.email)
      #expect(fieldName == "Email")
    }

    @Test func `extracts camelCase field name and adds spaces`() {
      let fieldName = extractFieldName(from: \TestState.userAge)
      #expect(fieldName == "User Age")
    }

    @Test func `extracts two-word camelCase field name`() {
      let fieldName = extractFieldName(from: \TestState.firstName)
      #expect(fieldName == "First Name")
    }

    @Test func `extracts long camelCase field name with multiple words`() {
      let fieldName = extractFieldName(from: \TestState.someVeryLongFieldName)
      #expect(fieldName == "Some Very Long Field Name")
    }

    @Test func `handles single letter field name`() {
      let fieldName = extractFieldName(from: \TestState.x)
      #expect(fieldName == "X")
    }

    @Test func `handles acronym in field name - splits each uppercase letter`() {
      // Note: This is documented behavior - acronyms are split by each uppercase letter
      let fieldName = extractFieldName(from: \TestState.userID)
      #expect(fieldName == "User I D")
    }
  }
}
