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
}

private struct TestState {
  var value: String = ""
  var valueError: String?
}
