import ComposableArchitecture
import Testing

@Suite("StringField")
@MainActor
struct StringFieldTests {

  @Suite("LengthRule")
  @MainActor
  struct LengthRuleTests {

    @Test func `binding with string shorter than 5 characters shows length error`() async {
      let store = TestStore(
        initialState: FormValidationTestReducer.State(),
        reducer: FormValidationTestReducer.init
      )

      await store.send(.set(\.stringField, "test")) {
        $0.stringField = "test"
        $0.stringFieldError = "Min length error"
      }
    }

    @Test func `binding with string exactly 5 characters passes length rule`() async {
      let store = TestStore(
        initialState: FormValidationTestReducer.State(),
        reducer: FormValidationTestReducer.init
      )

      await store.send(.set(\.stringField, "tests")) {
        $0.stringField = "tests"
        $0.stringFieldError = "Stringfield should be Test1"
      }
    }

    @Test func `submit with empty string shows length error`() async {
      let store = TestStore(
        initialState: FormValidationTestReducer.State(
          stringField: "",
          intField: 18,
          stringFieldError: nil,
          intFieldError: nil
        ),
        reducer: FormValidationTestReducer.init
      )

      await store.send(.submitForm) {
        $0.stringFieldError = "Min length error"
      }
    }
  }

  @Suite("IsEqualRule")
  @MainActor
  struct IsEqualRuleTests {

    @Test func `binding with string passing length but not equal shows isEqual error`() async {
      let store = TestStore(
        initialState: FormValidationTestReducer.State(),
        reducer: FormValidationTestReducer.init
      )

      await store.send(.set(\.stringField, "wrong")) {
        $0.stringField = "wrong"
        $0.stringFieldError = "Stringfield should be Test1"
      }
    }

    @Test func `binding with exact match Test1 clears error`() async {
      let store = TestStore(
        initialState: FormValidationTestReducer.State(
          stringField: "",
          intField: 0,
          stringFieldError: "Min length error",
          intFieldError: nil
        ),
        reducer: FormValidationTestReducer.init
      )

      await store.send(.set(\.stringField, "Test1")) {
        $0.stringField = "Test1"
        $0.stringFieldError = nil
      }
    }

    @Test func `submit with wrong value shows isEqual error`() async {
      let store = TestStore(
        initialState: FormValidationTestReducer.State(
          stringField: "wrong",
          intField: 18,
          stringFieldError: nil,
          intFieldError: nil
        ),
        reducer: FormValidationTestReducer.init
      )

      await store.send(.submitForm) {
        $0.stringFieldError = "Stringfield should be Test1"
      }
    }
  }

  @Suite("ErrorTransitions")
  @MainActor
  struct ErrorTransitionTests {

    @Test func `error transitions from length to isEqual to cleared`() async {
      let store = TestStore(
        initialState: FormValidationTestReducer.State(),
        reducer: FormValidationTestReducer.init
      )

      await store.send(.set(\.stringField, "ab")) {
        $0.stringField = "ab"
        $0.stringFieldError = "Min length error"
      }

      await store.send(.set(\.stringField, "abcde")) {
        $0.stringField = "abcde"
        $0.stringFieldError = "Stringfield should be Test1"
      }

      await store.send(.set(\.stringField, "Test1")) {
        $0.stringField = "Test1"
        $0.stringFieldError = nil
      }
    }
  }
}
