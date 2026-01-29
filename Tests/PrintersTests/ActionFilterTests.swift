import Testing

@testable import Printers

@Suite("ActionFilter Tests")
struct ActionFilterTests {
  enum TestAction {
    case a
    case b
    case c
  }

  @Suite(".all")
  struct AllTests {
    @Test func `returns true for any action`() {
      let filter = ActionFilter<TestAction>.all
      #expect(filter.isIncluded(.a))
      #expect(filter.isIncluded(.b))
      #expect(filter.isIncluded(.c))
    }
  }

  @Suite(".not")
  struct NotTests {
    @Test func `inverts filter that matches`() {
      let onlyA = ActionFilter<TestAction> { if case .a = $0 { true } else { false } }
      let notA = ActionFilter.not(onlyA)

      #expect(!notA.isIncluded(.a))
      #expect(notA.isIncluded(.b))
      #expect(notA.isIncluded(.c))
    }

    @Test func `inverts filter that does not match`() {
      let onlyA = ActionFilter<TestAction> { if case .a = $0 { true } else { false } }
      let notA = ActionFilter.not(onlyA)

      #expect(notA.isIncluded(.b))
      #expect(notA.isIncluded(.c))
    }

    @Test func `double negation returns original`() {
      let onlyA = ActionFilter<TestAction> { if case .a = $0 { true } else { false } }
      let notNotA = ActionFilter.not(.not(onlyA))

      #expect(notNotA.isIncluded(.a))
      #expect(!notNotA.isIncluded(.b))
    }
  }

  @Suite(".anyOf")
  struct AnyOfTests {
    @Test func `matches if any filter matches`() {
      let filterA = ActionFilter<TestAction> { if case .a = $0 { true } else { false } }
      let filterB = ActionFilter<TestAction> { if case .b = $0 { true } else { false } }
      let anyOf = ActionFilter.anyOf(filterA, filterB)

      #expect(anyOf.isIncluded(.a))
      #expect(anyOf.isIncluded(.b))
      #expect(!anyOf.isIncluded(.c))
    }

    @Test func `returns false when no filter matches`() {
      let filterA = ActionFilter<TestAction> { if case .a = $0 { true } else { false } }
      let filterB = ActionFilter<TestAction> { if case .b = $0 { true } else { false } }
      let anyOf = ActionFilter.anyOf(filterA, filterB)

      #expect(!anyOf.isIncluded(.c))
    }

    @Test func `works with array variant`() {
      let filterA = ActionFilter<TestAction> { if case .a = $0 { true } else { false } }
      let filterB = ActionFilter<TestAction> { if case .b = $0 { true } else { false } }
      let anyOf = ActionFilter.anyOf([filterA, filterB])

      #expect(anyOf.isIncluded(.a))
      #expect(anyOf.isIncluded(.b))
      #expect(!anyOf.isIncluded(.c))
    }
  }

  @Suite(".allExcept")
  struct AllExceptTests {
    @Test func `excludes specified actions`() {
      let filterA = ActionFilter<TestAction> { if case .a = $0 { true } else { false } }
      let allExceptA = ActionFilter.allExcept(filterA)

      #expect(!allExceptA.isIncluded(.a))
      #expect(allExceptA.isIncluded(.b))
      #expect(allExceptA.isIncluded(.c))
    }

    @Test func `excludes multiple actions`() {
      let filterA = ActionFilter<TestAction> { if case .a = $0 { true } else { false } }
      let filterB = ActionFilter<TestAction> { if case .b = $0 { true } else { false } }
      let allExceptAB = ActionFilter.allExcept(filterA, filterB)

      #expect(!allExceptAB.isIncluded(.a))
      #expect(!allExceptAB.isIncluded(.b))
      #expect(allExceptAB.isIncluded(.c))
    }

    @Test func `works with array variant`() {
      let filterA = ActionFilter<TestAction> { if case .a = $0 { true } else { false } }
      let filterB = ActionFilter<TestAction> { if case .b = $0 { true } else { false } }
      let allExceptAB = ActionFilter.allExcept([filterA, filterB])

      #expect(!allExceptAB.isIncluded(.a))
      #expect(!allExceptAB.isIncluded(.b))
      #expect(allExceptAB.isIncluded(.c))
    }
  }

  @Suite("Composability")
  struct ComposabilityTests {
    @Test func `nested filters work correctly`() {
      let filterA = ActionFilter<TestAction> { if case .a = $0 { true } else { false } }
      let filterB = ActionFilter<TestAction> { if case .b = $0 { true } else { false } }

      // anyOf(not(a), b) should include b and c, but not a (unless b matches, which it doesn't for a)
      let complexFilter = ActionFilter.anyOf(.not(filterA), filterB)

      #expect(!complexFilter.isIncluded(.a))  // not(a) is false for .a, and b doesn't match
      #expect(complexFilter.isIncluded(.b))  // b matches
      #expect(complexFilter.isIncluded(.c))  // not(a) is true for .c
    }

    @Test func `allExcept with anyOf combination`() {
      let filterA = ActionFilter<TestAction> { if case .a = $0 { true } else { false } }
      let filterB = ActionFilter<TestAction> { if case .b = $0 { true } else { false } }

      // Exclude a or b
      let excludeAOrB = ActionFilter.allExcept(.anyOf(filterA, filterB))

      #expect(!excludeAOrB.isIncluded(.a))
      #expect(!excludeAOrB.isIncluded(.b))
      #expect(excludeAOrB.isIncluded(.c))
    }
  }
}
