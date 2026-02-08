import Testing

@testable import FormValidation

@Suite("ValidationRule")
struct ValidationRuleTests {

  @Suite("Rule Validation")
  struct RuleValidationTests {

    @Test func `validation succeeds returns true`() {
      let rule = ValidationRule<String>.alwaysTrue()

      #expect(rule.validate("something") == true)
    }

    @Test func `validation fails returns false`() {
      let rule = ValidationRule<String>.alwaysFalse(withID: "1")

      #expect(rule.validate("something") == false)
    }
  }

  @Suite("List of Rules Validation")
  struct ListOfRulesValidationTests {

    @Test func `all rules succeed returns nil`() {
      let rules: [ValidationRule<String>] = [
        .alwaysTrue(),
        .alwaysTrue(),
        .alwaysTrue(),
      ]

      #expect(rules.validate("something") == nil)
    }

    @Test func `stops at first failing rule and returns its error message`() {
      let rules: [ValidationRule<String>] = [
        .alwaysTrue(),
        .alwaysFalse(withID: "1"),
        .alwaysFalse(withID: "2"),
      ]

      #expect(rules.validate("something") == "Test validation 1")
    }
  }

  @Suite("NonEmpty Rule")
  struct NonEmptyRuleTests {

    @Test func `non empty collection succeeds`() {
      assertSuccess(for: .nonEmpty(fieldName: "Test"), with: "something")
      assertSuccess(for: .nonEmpty(fieldName: "Test"), with: [1])
      assertSuccess(for: .nonEmpty(fieldName: "Test"), with: Set([1]))
      assertSuccess(for: .nonEmpty(fieldName: "Test"), with: ["something": 1])
    }

    @Test func `empty collection fails`() {
      assertFailure(for: .nonEmpty(fieldName: "Test"), with: "")
      assertFailure(for: .nonEmpty(fieldName: "Test"), with: [] as [Int])
      assertFailure(for: .nonEmpty(fieldName: "Test"), with: Set<Int>())
      assertFailure(for: .nonEmpty(fieldName: "Test"), with: [:] as [String: Int])
    }

    @Test func `nonEmpty without fieldName uses placeholder in error message`() {
      let rule: ValidationRule<String> = .nonEmpty()

      #expect(rule.validate("") == false)
      #expect(rule.errorMessage.contains("{fieldName}"))
    }
  }

  @Suite("Length Rule")
  struct LengthRuleTests {

    @Test func `collection with required number of elements succeeds`() {
      let rule: ValidationRule<String> = .length(min: 5, error: "Test validation")

      assertSuccess(for: rule, with: "somet")
      assertSuccess(for: rule, with: "something")
    }

    @Test func `collection with fewer elements than needed fails`() {
      let rule: ValidationRule<String> = .length(min: 5, error: "Test validation")

      assertFailure(for: rule, with: "")
      assertFailure(for: rule, with: "some")
    }
  }

  @Suite("GreaterOrEqual Rule")
  struct GreaterOrEqualRuleTests {

    @Test func `equal or greater value succeeds`() {
      let rule: ValidationRule<Int> = .greaterOrEqual(to: 10, fieldName: "Test")

      assertSuccess(for: rule, with: 10)
      assertSuccess(for: rule, with: 11)
    }

    @Test func `smaller value fails`() {
      let rule: ValidationRule<Int> = .greaterOrEqual(to: 10, fieldName: "Test")

      assertFailure(for: rule, with: 0)
    }

    @Test func `greaterOrEqual without fieldName uses placeholder in error message`() {
      let rule: ValidationRule<Int> = .greaterOrEqual(to: 10)

      #expect(rule.validate(5) == false)
      #expect(rule.errorMessage.contains("{fieldName}"))
    }
  }

  @Suite("IsEqual Rule")
  struct IsEqualRuleTests {

    @Test func `equal value succeeds`() {
      let rule: ValidationRule<Int> = .isEqual(to: 10, fieldName: "Test")

      assertSuccess(for: rule, with: 10)
    }

    @Test func `different value fails`() {
      let rule: ValidationRule<Int> = .isEqual(to: 10, fieldName: "Test")

      assertFailure(for: rule, with: 9)
      assertFailure(for: rule, with: 11)
    }

    @Test func `isEqual without fieldName uses placeholder in error message`() {
      let rule: ValidationRule<Int> = .isEqual(to: 10)

      #expect(rule.validate(5) == false)
      #expect(rule.errorMessage.contains("{fieldName}"))
    }
  }

  @Suite("NonOptional Rule")
  struct NonOptionalRuleTests {

    @Test func `with value succeeds`() {
      let rule: ValidationRule<Int?> = .nonOptional("Test")

      assertSuccess(for: rule, with: 10)
    }

    @Test func `with nil fails`() {
      let rule: ValidationRule<Int?> = .nonOptional("Test")

      assertFailure(for: rule, with: nil)
    }
  }
}

private func assertFailure<Value>(for rule: ValidationRule<Value>, with value: Value) {
  #expect(
    rule.validate(value) == false,
    "Rule succeeded while it was expected to fail with value: \(value)")
}

private func assertSuccess<Value>(for rule: ValidationRule<Value>, with value: Value) {
  #expect(
    rule.validate(value) == true,
    "Rule failed while it was expected to succeed with value: \(value)")
}
