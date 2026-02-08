#if !os(tvOS)

  import Testing

  @testable import DeviceInfo

  @Suite("BatteryInfo")
  struct DeviceInfoBatteryInfoTests {

    @Test func `zero battery has unknown state`() {
      let info = BatteryInfo.zero
      #expect(info.level == .zero)
      #expect(info.state == .unknown)
    }

    @Test func `DeviceBatteryState cases are distinct`() {
      let states: [DeviceBatteryState] = [.unknown, .unplugged, .charging, .full]
      for i in states.indices {
        for j in states.indices where i != j {
          #expect(states[i] != states[j])
        }
      }
    }

    @Test func `battery with custom values`() {
      let info = BatteryInfo(level: Percentage(rawValue: 0.85), state: .charging)
      #expect(info.level.rawValue == 0.85)
      #expect(info.state == .charging)
    }

    #if os(macOS)
      @Test func `macOS battery includes extended properties`() {
        let info = BatteryInfo(
          level: Percentage(rawValue: 0.9),
          state: .full,
          cycleCount: 150,
          temperature: 35.2,
          maxCapacity: Percentage(rawValue: 0.95),
          adapterName: "USB-C"
        )
        #expect(info.cycleCount == 150)
        #expect(info.temperature == 35.2)
        #expect(info.maxCapacity?.rawValue == 0.95)
        #expect(info.adapterName == "USB-C")
      }

      @Test func `macOS battery nil extended properties`() {
        let info = BatteryInfo(level: Percentage(rawValue: 0.5), state: .unplugged)
        #expect(info.cycleCount == nil)
        #expect(info.temperature == nil)
        #expect(info.maxCapacity == nil)
        #expect(info.adapterName == nil)
      }
    #endif
  }

#endif
