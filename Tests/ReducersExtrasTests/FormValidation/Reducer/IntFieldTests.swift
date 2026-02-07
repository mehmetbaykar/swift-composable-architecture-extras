import ComposableArchitecture
import Testing

@Suite("IntField")
@MainActor
struct IntFieldTests {

  @Suite("GreaterOrEqualRule")
  @MainActor
  struct GreaterOrEqualRuleTests {

    @Test func `binding with value below 18 shows error`() async {
      let store = TestStore(
        initialState: FormValidationTestReducer.State(),
        reducer: FormValidationTestReducer.init
      )

      await store.send(.set(\.intField, 17)) {
        $0.intField = 17
        $0.intFieldError = "Intfield should be greater or equal to 18"
      }
    }

    @Test func `binding with value exactly 18 clears error`() async {
      let store = TestStore(
        initialState: FormValidationTestReducer.State(
          stringField: "",
          intField: 0,
          stringFieldError: nil,
          intFieldError: "Intfield should be greater or equal to 18"
        ),
        reducer: FormValidationTestReducer.init
      )

      await store.send(.set(\.intField, 18)) {
        $0.intField = 18
        $0.intFieldError = nil
      }
    }

    @Test func `binding with value above 18 clears error`() async {
      let store = TestStore(
        initialState: FormValidationTestReducer.State(
          stringField: "",
          intField: 0,
          stringFieldError: nil,
          intFieldError: "Intfield should be greater or equal to 18"
        ),
        reducer: FormValidationTestReducer.init
      )

      await store.send(.set(\.intField, 21)) {
        $0.intField = 21
        $0.intFieldError = nil
      }
    }

    @Test func `submit with zero shows age error`() async {
      let store = TestStore(
        initialState: FormValidationTestReducer.State(
          stringField: "Test1",
          intField: 0,
          stringFieldError: nil,
          intFieldError: nil
        ),
        reducer: FormValidationTestReducer.init
      )

      await store.send(.submitForm) {
        $0.intFieldError = "Intfield should be greater or equal to 18"
      }
    }
  }
}
