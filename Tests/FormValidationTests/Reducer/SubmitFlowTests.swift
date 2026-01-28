import ComposableArchitecture
import Testing

@Suite("SubmitFlow")
@MainActor
struct SubmitFlowTests {

  @Test func `submit with all invalid fields shows all errors and no effect`() async {
    let store = TestStore(
      initialState: TestReducer.State(
        stringField: "",
        intField: 0,
        stringFieldError: nil,
        intFieldError: nil
      ),
      reducer: TestReducer.init
    )

    await store.send(.submitForm) {
      $0.stringFieldError = "Min length error"
      $0.intFieldError = "Intfield should be greater or equal to 18"
    }
  }

  @Test func `submit with partial valid shows remaining errors and no effect`() async {
    let store = TestStore(
      initialState: TestReducer.State(
        stringField: "Test1",
        intField: 0,
        stringFieldError: nil,
        intFieldError: nil
      ),
      reducer: TestReducer.init
    )

    await store.send(.submitForm) {
      $0.intFieldError = "Intfield should be greater or equal to 18"
    }
  }

  @Test func `submit with all valid fields clears errors and emits success`() async {
    let store = TestStore(
      initialState: TestReducer.State(
        stringField: "Test1",
        intField: 18,
        stringFieldError: "Previous error",
        intFieldError: "Previous error"
      ),
      reducer: TestReducer.init
    )

    await store.send(.submitForm) {
      $0.stringFieldError = nil
      $0.intFieldError = nil
    }

    await store.receive(\.formValidationSucceed)
  }
}
