import ComposableArchitecture

@testable import FormValidation

@Reducer
struct FormValidationTestReducer {
  @ObservableState
  struct State: Equatable {
    var stringField = ""
    var intField = 0

    var stringFieldError: String?
    var intFieldError: String?
  }

  enum Action: BindableAction {
    case binding(BindingAction<State>)
    case submitForm
    case formValidationSucceed
  }

  var body: some ReducerOf<Self> {
    BindingReducer()

    FormValidationReducer(
      submitAction: \.submitForm,
      onFormValidatedAction: .formValidationSucceed,
      validations: [
        .minLength5,
        .intFieldGreaterOrEqualTo18,
      ]
    )
  }
}

extension FieldValidation where State == FormValidationTestReducer.State {
  static var minLength5: FieldValidation {
    FieldValidation(
      field: \.stringField,
      errorState: \.stringFieldError,
      rules: [
        .length(min: 5, error: "Min length error"),
        .isEqual(to: "Test1", fieldName: "stringField"),
      ]
    )
  }

  static var intFieldGreaterOrEqualTo18: FieldValidation {
    FieldValidation(
      field: \.intField,
      errorState: \.intFieldError,
      rules: [
        .greaterOrEqual(to: 18, fieldName: "intField")
      ]
    )
  }
}
