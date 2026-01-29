import Dependencies
import XCTestDynamicOverlay

@usableFromInline
struct AnyFeedbackGeneratorClient: Sendable {
  @usableFromInline
  let _prepare: @Sendable (HapticFeedback) async -> Void

  @usableFromInline
  let _generate: @Sendable (HapticFeedback) async -> Void

  @usableFromInline
  init(_ client: FeedbackGeneratorClient) {
    self._prepare = client.prepare
    self._generate = client.generate
  }

  @usableFromInline
  init(
    prepare: @escaping @Sendable (HapticFeedback) async -> Void,
    generate: @escaping @Sendable (HapticFeedback) async -> Void
  ) {
    self._prepare = prepare
    self._generate = generate
  }

  @usableFromInline
  func prepare(_ feedback: HapticFeedback) async {
    await _prepare(feedback)
  }

  @usableFromInline
  func generate(_ feedback: HapticFeedback) async {
    await _generate(feedback)
  }
}

extension AnyFeedbackGeneratorClient: TestDependencyKey {
  @usableFromInline
  static var testValue: Self {
    Self(
      prepare: { _ in
        XCTFail("Unimplemented: FeedbackGeneratorClient.prepare")
      },
      generate: { _ in
        XCTFail("Unimplemented: FeedbackGeneratorClient.generate")
      }
    )
  }

  @usableFromInline
  static var previewValue: Self {
    Self(.consoleLogger())
  }
}

extension DependencyValues {
  var feedbackGenerator: AnyFeedbackGeneratorClient {
    get { self[AnyFeedbackGeneratorClient.self] }
    set { self[AnyFeedbackGeneratorClient.self] = newValue }
  }
}
