import Foundation

public struct ActionFilter<Action>: Sendable {
  let isIncluded: @Sendable (Action) -> Bool

  public init(isIncluded: @Sendable @escaping (Action) -> Bool) {
    self.isIncluded = isIncluded
  }

  func callAsFunction(_ action: Action) -> Bool {
    isIncluded(action)
  }

  public static var all: Self {
    .init(isIncluded: { _ in true })
  }

  public static func not(_ filter: Self) -> Self {
    .init(isIncluded: { !filter($0) })
  }

  public static func allExcept(_ actions: Self...) -> Self {
    allExcept(actions)
  }

  public static func allExcept(_ actions: [Self]) -> Self {
    .init(isIncluded: { action in
      !actions.contains(where: { $0(action) })
    })
  }

  public static func anyOf(_ actions: Self...) -> Self {
    .anyOf(actions)
  }

  public static func anyOf(_ actions: [Self]) -> Self {
    .init(isIncluded: { action in
      actions.contains(where: { $0(action) })
    })
  }
}
