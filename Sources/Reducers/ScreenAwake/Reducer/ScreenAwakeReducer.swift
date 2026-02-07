import ComposableArchitecture

extension Reducer {
  public func screenAwake(
    when trigger: @escaping (State) -> Bool
  ) -> some ReducerOf<Self> {
    DeviceScreenAwakeReducer(base: self, trigger: trigger)
  }
}

@Reducer
private struct DeviceScreenAwakeReducer<Base: Reducer> {
  let base: Base
  let trigger: (Base.State) -> Bool

  @Dependency(\.deviceScreenAwake) var deviceScreenAwake

  var body: some ReducerOf<Base> {
    self.base.onChange(of: self.trigger) { _, newValue in
      Reduce { state, _ in
        return .run { [deviceScreenAwake] _ in
          if newValue {
            await deviceScreenAwake.enable()
          } else {
            await deviceScreenAwake.disable()
          }
        }
      }
    }
  }
}
