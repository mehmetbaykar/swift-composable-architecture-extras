#if os(iOS) || os(tvOS) || os(watchOS)
  import DeviceKit

  enum MarketingName {
    static func current() -> String {
      let device = Device.current
      if case .simulator(let inner) = device {
        return inner.description
      }
      return device.description
    }
  }
#endif
