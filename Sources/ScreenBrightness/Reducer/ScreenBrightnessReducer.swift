import ComposableArchitecture

extension Reducer {
  @inlinable
  public func screenBrightness(
    level trigger: @escaping (State) -> BrightnessLevel
  ) -> some ReducerOf<Self> {
    _ScreenBrightnessReducer(
      base: self,
      trigger: trigger
    )
  }
}

@Reducer
@usableFromInline
struct _ScreenBrightnessReducer<Base: Reducer> {
  @usableFromInline
  let base: Base
  @usableFromInline
  let trigger: (Base.State) -> BrightnessLevel

  @Dependency(\.screenBrightness) var screenBrightness

  @usableFromInline
  init(base: Base, trigger: @escaping (Base.State) -> BrightnessLevel) {
    self.base = base
    self.trigger = trigger
  }

  @usableFromInline
  var body: some ReducerOf<Base> {
    self.base.onChange(of: self.trigger) { _, newValue in
      Reduce { _, _ in
        return .run { [screenBrightness] _ in
          await screenBrightness.set(newValue)
        }
      }
    }
  }
}
