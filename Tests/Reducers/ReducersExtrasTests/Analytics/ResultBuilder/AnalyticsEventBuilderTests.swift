import Testing

@testable import Analytics

@Suite("AnalyticsEventBuilder Tests")
struct AnalyticsEventBuilderTests {
  enum TestEvent: Sendable, Equatable {
    case event1
    case event2
    case event3
    case eventWithValue(Int)
  }

  @Suite("buildBlock")
  struct BuildBlockTests {
    @Test("empty block returns empty array")
    func emptyBlockReturnsEmptyArray() {
      @AnalyticsEventBuilder<TestEvent>
      func build() -> [TestEvent] {
        // Empty
      }

      #expect(build() == [])
    }

    @Test("single statement block returns single event")
    func singleStatementBlock() {
      @AnalyticsEventBuilder<TestEvent>
      func build() -> [TestEvent] {
        TestEvent.event1
      }

      #expect(build() == [.event1])
    }

    @Test("multiple statements combine into array")
    func multipleStatementsCombine() {
      @AnalyticsEventBuilder<TestEvent>
      func build() -> [TestEvent] {
        TestEvent.event1
        TestEvent.event2
        TestEvent.event3
      }

      #expect(build() == [.event1, .event2, .event3])
    }
  }

  @Suite("buildExpression")
  struct BuildExpressionTests {
    @Test("single event expression")
    func singleEventExpression() {
      @AnalyticsEventBuilder<TestEvent>
      func build() -> [TestEvent] {
        TestEvent.event1
      }

      #expect(build() == [.event1])
    }

    @Test("array expression")
    func arrayExpression() {
      @AnalyticsEventBuilder<TestEvent>
      func build() -> [TestEvent] {
        [TestEvent.event1, TestEvent.event2]
      }

      #expect(build() == [.event1, .event2])
    }

    @Test("mixed expressions combine correctly")
    func mixedExpressions() {
      @AnalyticsEventBuilder<TestEvent>
      func build() -> [TestEvent] {
        TestEvent.event1
        [TestEvent.event2, TestEvent.event3]
      }

      #expect(build() == [.event1, .event2, .event3])
    }
  }

  @Suite("buildOptional")
  struct BuildOptionalTests {
    @Test("if condition true emits event")
    func ifConditionTrueEmitsEvent() {
      @AnalyticsEventBuilder<TestEvent>
      func build(condition: Bool) -> [TestEvent] {
        if condition {
          TestEvent.event1
        }
      }

      #expect(build(condition: true) == [.event1])
    }

    @Test("if condition false emits nothing")
    func ifConditionFalseEmitsNothing() {
      @AnalyticsEventBuilder<TestEvent>
      func build(condition: Bool) -> [TestEvent] {
        if condition {
          TestEvent.event1
        }
      }

      #expect(build(condition: false) == [])
    }

    @Test("optional with surrounding events")
    func optionalWithSurroundingEvents() {
      @AnalyticsEventBuilder<TestEvent>
      func build(condition: Bool) -> [TestEvent] {
        TestEvent.event1
        if condition {
          TestEvent.event2
        }
        TestEvent.event3
      }

      #expect(build(condition: true) == [.event1, .event2, .event3])
      #expect(build(condition: false) == [.event1, .event3])
    }
  }

  @Suite("buildEither")
  struct BuildEitherTests {
    @Test("if-else first branch")
    func ifElseFirstBranch() {
      @AnalyticsEventBuilder<TestEvent>
      func build(condition: Bool) -> [TestEvent] {
        if condition {
          TestEvent.event1
        } else {
          TestEvent.event2
        }
      }

      #expect(build(condition: true) == [.event1])
    }

    @Test("if-else second branch")
    func ifElseSecondBranch() {
      @AnalyticsEventBuilder<TestEvent>
      func build(condition: Bool) -> [TestEvent] {
        if condition {
          TestEvent.event1
        } else {
          TestEvent.event2
        }
      }

      #expect(build(condition: false) == [.event2])
    }

    @Test("nested if-else")
    func nestedIfElse() {
      @AnalyticsEventBuilder<TestEvent>
      func build(a: Bool, b: Bool) -> [TestEvent] {
        if a {
          if b {
            TestEvent.event1
          } else {
            TestEvent.event2
          }
        } else {
          TestEvent.event3
        }
      }

      #expect(build(a: true, b: true) == [.event1])
      #expect(build(a: true, b: false) == [.event2])
      #expect(build(a: false, b: true) == [.event3])
      #expect(build(a: false, b: false) == [.event3])
    }

    @Test("switch statement")
    func switchStatement() {
      enum Choice { case a, b, c }

      @AnalyticsEventBuilder<TestEvent>
      func build(choice: Choice) -> [TestEvent] {
        switch choice {
        case .a:
          TestEvent.event1
        case .b:
          TestEvent.event2
        case .c:
          TestEvent.event3
        }
      }

      #expect(build(choice: .a) == [.event1])
      #expect(build(choice: .b) == [.event2])
      #expect(build(choice: .c) == [.event3])
    }
  }

  @Suite("buildArray")
  struct BuildArrayTests {
    @Test("for-in loop over collection")
    func forInLoopOverCollection() {
      @AnalyticsEventBuilder<TestEvent>
      func build(values: [Int]) -> [TestEvent] {
        for value in values {
          TestEvent.eventWithValue(value)
        }
      }

      #expect(
        build(values: [1, 2, 3]) == [.eventWithValue(1), .eventWithValue(2), .eventWithValue(3)])
    }

    @Test("for-in with empty collection")
    func forInWithEmptyCollection() {
      @AnalyticsEventBuilder<TestEvent>
      func build(values: [Int]) -> [TestEvent] {
        for value in values {
          TestEvent.eventWithValue(value)
        }
      }

      #expect(build(values: []) == [])
    }

    @Test("for-in with surrounding events")
    func forInWithSurroundingEvents() {
      @AnalyticsEventBuilder<TestEvent>
      func build(values: [Int]) -> [TestEvent] {
        TestEvent.event1
        for value in values {
          TestEvent.eventWithValue(value)
        }
        TestEvent.event2
      }

      #expect(build(values: [1, 2]) == [.event1, .eventWithValue(1), .eventWithValue(2), .event2])
    }

    @Test("for-in with conditional inside")
    func forInWithConditionalInside() {
      @AnalyticsEventBuilder<TestEvent>
      func build(values: [Int]) -> [TestEvent] {
        for value in values {
          if value > 0 {
            TestEvent.eventWithValue(value)
          }
        }
      }

      #expect(build(values: [-1, 0, 1, 2]) == [.eventWithValue(1), .eventWithValue(2)])
    }
  }

  @Suite("buildLimitedAvailability")
  struct BuildLimitedAvailabilityTests {
    @Test("available check passthrough")
    func availableCheckPassthrough() {
      @AnalyticsEventBuilder<TestEvent>
      func build() -> [TestEvent] {
        if #available(iOS 13, macOS 10.15, *) {
          TestEvent.event1
        }
      }

      #expect(build() == [.event1])
    }
  }

  @Suite("Complex scenarios")
  struct ComplexScenarioTests {
    @Test("switch with multiple events per case")
    func switchWithMultipleEventsPerCase() {
      enum Action { case a, b }

      @AnalyticsEventBuilder<TestEvent>
      func build(action: Action) -> [TestEvent] {
        switch action {
        case .a:
          TestEvent.event1
          TestEvent.event2
        case .b:
          TestEvent.event3
        }
      }

      #expect(build(action: .a) == [.event1, .event2])
      #expect(build(action: .b) == [.event3])
    }

    @Test("conditional event based on state")
    func conditionalEventBasedOnState() {
      struct State {
        var isLoggedIn: Bool
        var hasSubscription: Bool
      }

      @AnalyticsEventBuilder<TestEvent>
      func build(state: State) -> [TestEvent] {
        if state.isLoggedIn {
          TestEvent.event1
          if state.hasSubscription {
            TestEvent.event2
          }
        }
      }

      #expect(build(state: State(isLoggedIn: true, hasSubscription: true)) == [.event1, .event2])
      #expect(build(state: State(isLoggedIn: true, hasSubscription: false)) == [.event1])
      #expect(build(state: State(isLoggedIn: false, hasSubscription: true)) == [])
    }

    @Test("for-in with if-else")
    func forInWithIfElse() {
      @AnalyticsEventBuilder<TestEvent>
      func build(values: [Int]) -> [TestEvent] {
        for value in values {
          if value > 0 {
            TestEvent.eventWithValue(value)
          } else {
            TestEvent.event1
          }
        }
      }

      #expect(
        build(values: [-1, 0, 1, 2]) == [.event1, .event1, .eventWithValue(1), .eventWithValue(2)])
    }
  }
}
