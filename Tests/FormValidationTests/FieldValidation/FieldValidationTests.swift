import Testing

@testable import FormValidation

@Suite("FieldValidation")
@MainActor
struct FieldValidationTests {

  @Test func `successful validation sets error to nil`() {
    var state = TestState(valueError: "Initial error")
    let fieldValidation = FieldValidation(
      field: \TestState.value,
      errorState: \TestState.valueError,
      rules: [
        .alwaysTrue(),
        .alwaysTrue(),
      ]
    )

    let result = fieldValidation.validate(state: &state)

    #expect(result == true)
    #expect(state.valueError == nil)
  }

  @Test func `failing validation sets first failing rule error`() {
    var state = TestState(valueError: "Initial error")
    let fieldValidation = FieldValidation(
      field: \TestState.value,
      errorState: \TestState.valueError,
      rules: [
        .alwaysTrue(),
        .alwaysFalse(withID: "1"),
        .alwaysFalse(withID: "2"),
      ]
    )

    let result = fieldValidation.validate(state: &state)

    #expect(result == false)
    #expect(state.valueError == "Test validation 1")
  }

  @Suite("Auto Field Name")
  @MainActor
  struct AutoFieldNameTests {

    @Test func `enriches nonEmpty rule with field name from keypath`() {
      var state = AutoFieldNameTestState()
      let fieldValidation = FieldValidation(
        field: \AutoFieldNameTestState.email,
        errorState: \AutoFieldNameTestState.emailError,
        rules: [.nonEmpty()]
      )

      let result = fieldValidation.validate(state: &state)

      #expect(result == false)
      #expect(state.emailError == "Email should not be empty")
    }

    @Test func `enriches greaterOrEqual rule with field name from keypath`() {
      var state = AutoFieldNameTestState(userAge: 10)
      let fieldValidation = FieldValidation(
        field: \AutoFieldNameTestState.userAge,
        errorState: \AutoFieldNameTestState.userAgeError,
        rules: [.greaterOrEqual(to: 18)]
      )

      let result = fieldValidation.validate(state: &state)

      #expect(result == false)
      #expect(state.userAgeError == "User Age should be greater or equal to 18")
    }

    @Test func `enriches isEqual rule with field name from keypath`() {
      var state = AutoFieldNameTestState(firstName: "Jane")
      let fieldValidation = FieldValidation(
        field: \AutoFieldNameTestState.firstName,
        errorState: \AutoFieldNameTestState.firstNameError,
        rules: [.isEqual(to: "John")]
      )

      let result = fieldValidation.validate(state: &state)

      #expect(result == false)
      #expect(state.firstNameError == "First Name should be John")
    }

    @Test func `clears error when validation succeeds`() {
      var state = AutoFieldNameTestState(email: "test@example.com", emailError: "Previous error")
      let fieldValidation = FieldValidation(
        field: \AutoFieldNameTestState.email,
        errorState: \AutoFieldNameTestState.emailError,
        rules: [.nonEmpty()]
      )

      let result = fieldValidation.validate(state: &state)

      #expect(result == true)
      #expect(state.emailError == nil)
    }

    @Test func `explicit fieldName rules are not affected by auto enrichment`() {
      var state = AutoFieldNameTestState()
      let fieldValidation = FieldValidation(
        field: \AutoFieldNameTestState.email,
        errorState: \AutoFieldNameTestState.emailError,
        rules: [.nonEmpty(fieldName: "Custom Name")]
      )

      let result = fieldValidation.validate(state: &state)

      #expect(result == false)
      #expect(state.emailError == "Custom Name should not be empty")
    }

    @Test func `length rule with custom error is not affected`() {
      var state = AutoFieldNameTestState(email: "ab")
      let fieldValidation = FieldValidation(
        field: \AutoFieldNameTestState.email,
        errorState: \AutoFieldNameTestState.emailError,
        rules: [.length(min: 5, error: "Too short")]
      )

      let result = fieldValidation.validate(state: &state)

      #expect(result == false)
      #expect(state.emailError == "Too short")
    }

    @Test func `multiple auto rules with same field name`() {
      var state = AutoFieldNameTestState(email: "")
      let fieldValidation = FieldValidation(
        field: \AutoFieldNameTestState.email,
        errorState: \AutoFieldNameTestState.emailError,
        rules: [
          .nonEmpty(),
          .isEqual(to: "test@example.com"),
        ]
      )

      // First rule should fail with auto field name
      let result = fieldValidation.validate(state: &state)

      #expect(result == false)
      #expect(state.emailError == "Email should not be empty")
    }
  }
}

private struct TestState {
  var value: String = ""
  var valueError: String?
}

private struct AutoFieldNameTestState {
  var email: String = ""
  var emailError: String?
  var userAge: Int = 0
  var userAgeError: String?
  var firstName: String = ""
  var firstNameError: String?
}
