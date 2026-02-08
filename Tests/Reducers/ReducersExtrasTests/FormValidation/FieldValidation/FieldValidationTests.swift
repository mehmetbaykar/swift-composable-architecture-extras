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

  @Suite("Auto-derived field name")
  @MainActor
  struct AutoDerivedFieldNameTests {

    @Test func `nonEmpty rule without fieldName derives name from keypath`() {
      var state = AutoDeriveState()
      let fieldValidation = FieldValidation(
        field: \AutoDeriveState.email,
        errorState: \AutoDeriveState.emailError,
        rules: [.nonEmpty()]
      )

      let result = fieldValidation.validate(state: &state)

      #expect(result == false)
      #expect(state.emailError == "Email should not be empty")
    }

    @Test func `greaterOrEqual rule without fieldName derives name from keypath`() {
      var state = AutoDeriveState()
      let fieldValidation = FieldValidation(
        field: \AutoDeriveState.age,
        errorState: \AutoDeriveState.ageError,
        rules: [.greaterOrEqual(to: 18)]
      )

      let result = fieldValidation.validate(state: &state)

      #expect(result == false)
      #expect(state.ageError == "Age should be greater or equal to 18")
    }

    @Test func `isEqual rule without fieldName derives name from keypath`() {
      var state = AutoDeriveState(email: "wrong")
      let fieldValidation = FieldValidation(
        field: \AutoDeriveState.email,
        errorState: \AutoDeriveState.emailError,
        rules: [.isEqual(to: "test@example.com")]
      )

      let result = fieldValidation.validate(state: &state)

      #expect(result == false)
      #expect(state.emailError == "Email should be test@example.com")
    }

    @Test func `auto-derived rule clears error on successful validation`() {
      var state = AutoDeriveState(email: "hello", emailError: "Previous error")
      let fieldValidation = FieldValidation(
        field: \AutoDeriveState.email,
        errorState: \AutoDeriveState.emailError,
        rules: [.nonEmpty()]
      )

      let result = fieldValidation.validate(state: &state)

      #expect(result == true)
      #expect(state.emailError == nil)
    }
  }
}

private struct TestState {
  var value: String = ""
  var valueError: String?
}

private struct AutoDeriveState {
  var email: String = ""
  var age: Int = 0
  var emailError: String?
  var ageError: String?
}
