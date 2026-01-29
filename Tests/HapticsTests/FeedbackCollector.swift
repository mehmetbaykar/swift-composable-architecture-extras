import Foundation

@testable import Haptics

final class FeedbackCollector: @unchecked Sendable {
  private let lock = NSLock()
  private var _feedbacks: [HapticFeedback] = []
  private var _prepares: [HapticFeedback] = []

  var feedbacks: [HapticFeedback] {
    lock.lock()
    defer { lock.unlock() }
    return _feedbacks
  }

  var prepares: [HapticFeedback] {
    lock.lock()
    defer { lock.unlock() }
    return _prepares
  }

  func appendFeedback(_ feedback: HapticFeedback) {
    lock.lock()
    defer { lock.unlock() }
    _feedbacks.append(feedback)
  }

  func appendPrepare(_ feedback: HapticFeedback) {
    lock.lock()
    defer { lock.unlock() }
    _prepares.append(feedback)
  }

  func reset() {
    lock.lock()
    defer { lock.unlock() }
    _feedbacks.removeAll()
    _prepares.removeAll()
  }

  var client: FeedbackGeneratorClient {
    FeedbackGeneratorClient(
      prepare: { [weak self] feedback in
        self?.appendPrepare(feedback)
      },
      generate: { [weak self] feedback in
        self?.appendFeedback(feedback)
      }
    )
  }
}
