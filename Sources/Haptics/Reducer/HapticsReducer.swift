import ComposableArchitecture

extension Reducer {
  @inlinable
  public func haptics<Trigger: Equatable>(
    _ feedback: HapticFeedback,
    triggerOnChangeOf trigger: @escaping (State) -> Trigger,
    isEnabled: @escaping (State) -> Bool = { _ in true }
  ) -> some ReducerOf<Self> {
    _HapticsReducer(base: self, feedback: feedback, trigger: trigger, isEnabled: isEnabled)
  }

  @inlinable
  public func haptics<Trigger: Equatable>(
    _ feedback: HapticFeedback,
    triggerOnChangeOf trigger: @escaping (State) -> Trigger,
    isEnabled: KeyPath<State, Bool>
  ) -> some ReducerOf<Self> {
    _HapticsReducer(
      base: self, feedback: feedback, trigger: trigger, isEnabled: { $0[keyPath: isEnabled] })
  }
}

@Reducer
@usableFromInline
struct _HapticsReducer<Base: Reducer, Trigger: Equatable>: Reducer {
  @usableFromInline
  let base: Base

  @usableFromInline
  let feedback: HapticFeedback

  @usableFromInline
  let trigger: (Base.State) -> Trigger

  @usableFromInline
  let isEnabled: (Base.State) -> Bool

  @Dependency(\.feedbackGenerator) var feedbackGenerator

  @usableFromInline
  init(
    base: Base,
    feedback: HapticFeedback,
    trigger: @escaping (Base.State) -> Trigger,
    isEnabled: @escaping (Base.State) -> Bool
  ) {
    self.base = base
    self.feedback = feedback
    self.trigger = trigger
    self.isEnabled = isEnabled
  }

  @usableFromInline
  var body: some ReducerOf<Base> {
    base.onChange(of: trigger) { _, _ in
      Reduce { state, _ in
        guard isEnabled(state) else { return .none }
        return .run { [feedbackGenerator, feedback] _ in
          await feedbackGenerator.generate(feedback)
        }
      }
    }
  }
}
