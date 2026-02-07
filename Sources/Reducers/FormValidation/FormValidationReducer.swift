import ComposableArchitecture
import Foundation

public struct FormValidationReducer<State, Action, ViewAction>: Reducer
where State == ViewAction.State, ViewAction: BindableAction {
  let toViewAction: (Action) -> ViewAction?
  let submitAction: CaseKeyPath<ViewAction, Void>
  let onFormValidatedAction: Action
  let validations: [FieldValidation<State>]

  public init(
    viewAction toViewAction: @escaping (_ action: Action) -> ViewAction?,
    submitAction: CaseKeyPath<ViewAction, Void>,
    onFormValidatedAction: Action,
    validations: [FieldValidation<State>]
  ) {
    self.toViewAction = toViewAction
    self.submitAction = submitAction
    self.onFormValidatedAction = onFormValidatedAction
    self.validations = validations
  }

  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    if let viewAction = toViewAction(action),
      AnyCasePath(submitAction).extract(from: viewAction) != nil
    {
      let didSucceed = validateAllFields(state: &state)

      return didSucceed ? .send(onFormValidatedAction) : .none
    }

    if let validation = getFirstValidation(for: action) {
      validation.validate(state: &state)
    }

    return .none
  }

  private func validateAllFields(state: inout State) -> Bool {
    validations.reduce(true) { $1.validate(state: &state) && $0 }
  }

  private func getFirstValidation(for action: Action) -> FieldValidation<State>? {
    let binding = toViewAction(action).flatMap(\.binding)

    return validations.first(where: { $0.binding == binding?.keyPath })
  }
}

extension FormValidationReducer {
  public init(
    viewAction toViewAction: CaseKeyPath<Action, ViewAction>,
    submitAction: CaseKeyPath<ViewAction, Void>,
    onFormValidatedAction: Action,
    validations: [FieldValidation<State>]
  ) where Action: CasePathable {
    self.init(
      viewAction: { $0[case: toViewAction] },
      submitAction: submitAction,
      onFormValidatedAction: onFormValidatedAction,
      validations: validations
    )
  }

  public init(
    submitAction: CaseKeyPath<ViewAction, Void>,
    onFormValidatedAction: Action,
    validations: [FieldValidation<State>]
  ) where Action == ViewAction {
    self.init(
      viewAction: { $0 },
      submitAction: submitAction,
      onFormValidatedAction: onFormValidatedAction,
      validations: validations
    )
  }
}
