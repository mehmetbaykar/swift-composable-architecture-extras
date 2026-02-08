import Testing

@testable import DeviceInfo

@Suite("DeviceInfo Models")
struct DeviceInfoModelTests {

  @Suite("CPUInfo")
  struct CPUInfoTests {

    @Test func `zero has all zero percentages`() {
      let info = CPUInfo.zero
      #expect(info.usage == .zero)
      #expect(info.user == .zero)
      #expect(info.system == .zero)
      #expect(info.idle == .zero)
    }

    @Test func `equality works`() {
      let a = CPUInfo(
        usage: Percentage(rawValue: 0.5),
        user: Percentage(rawValue: 0.3),
        system: Percentage(rawValue: 0.2),
        idle: Percentage(rawValue: 0.5)
      )
      let b = CPUInfo(
        usage: Percentage(rawValue: 0.5),
        user: Percentage(rawValue: 0.3),
        system: Percentage(rawValue: 0.2),
        idle: Percentage(rawValue: 0.5)
      )
      #expect(a == b)
    }
  }

  @Suite("MemoryInfo")
  struct MemoryInfoTests {

    @Test func `zero has all zero values`() {
      let info = MemoryInfo.zero
      #expect(info.usage == .zero)
      #expect(info.total == .zero)
      #expect(info.used == .zero)
      #expect(info.available == .zero)
    }

    @Test func `equality works`() {
      let a = MemoryInfo(
        usage: Percentage(rawValue: 0.5),
        total: ByteCount(bytes: 8_000_000_000),
        used: ByteCount(bytes: 4_000_000_000),
        available: ByteCount(bytes: 4_000_000_000)
      )
      let b = MemoryInfo(
        usage: Percentage(rawValue: 0.5),
        total: ByteCount(bytes: 8_000_000_000),
        used: ByteCount(bytes: 4_000_000_000),
        available: ByteCount(bytes: 4_000_000_000)
      )
      #expect(a == b)
    }
  }

  @Suite("DiskInfo")
  struct DiskInfoTests {

    @Test func `zero has all zero values`() {
      let info = DiskInfo.zero
      #expect(info.usage == .zero)
      #expect(info.total == .zero)
      #expect(info.used == .zero)
      #expect(info.available == .zero)
    }
  }

  @Suite("DeviceThermalState")
  struct DeviceThermalStateTests {

    @Test func `all cases are distinct`() {
      let cases: [DeviceThermalState] = [.nominal, .fair, .serious, .critical]
      for i in cases.indices {
        for j in cases.indices where i != j {
          #expect(cases[i] != cases[j])
        }
      }
    }
  }

  @Suite("DeviceIdentity")
  struct DeviceIdentityTests {

    @Test func `empty has all empty strings`() {
      let identity = DeviceIdentity.empty
      #expect(identity.name == "")
      #expect(identity.model == "")
      #expect(identity.systemName == "")
      #expect(identity.systemVersion == "")
    }

    @Test func `equality works`() {
      let a = DeviceIdentity(
        name: "iPhone", model: "iPhone15,2", systemName: "iOS", systemVersion: "17.0",
        totalCoreCount: 6, activeCoreCount: 6, isiOSAppOnMac: false)
      let b = DeviceIdentity(
        name: "iPhone", model: "iPhone15,2", systemName: "iOS", systemVersion: "17.0",
        totalCoreCount: 6, activeCoreCount: 6, isiOSAppOnMac: false)
      #expect(a == b)
    }
  }

  #if !os(watchOS)
    @Suite("NetworkInfo")
    struct NetworkInfoTests {

      @Test func `disconnected has correct defaults`() {
        let info = NetworkInfo.disconnected
        #expect(info.isConnected == false)
        #expect(info.interfaceType == .unknown)
      }

      @Test func `all interface types are distinct`() {
        let types: [NetworkInterfaceType] = [.wifi, .cellular, .wiredEthernet, .loopback, .unknown]
        for i in types.indices {
          for j in types.indices where i != j {
            #expect(types[i] != types[j])
          }
        }
      }
    }
  #endif

  #if !os(visionOS)
    @Suite("ScreenInfo")
    struct ScreenInfoTests {

      @Test func `zero has all zero values`() {
        let info = ScreenInfo.zero
        #expect(info.width == 0)
        #expect(info.height == 0)
        #expect(info.scale == 0)
      }

      @Test func `equality works`() {
        let a = ScreenInfo.zero
        let b = ScreenInfo.zero
        #expect(a == b)
      }

      #if os(iOS)
        @Test func `zero has false booleans on iOS`() {
          let info = ScreenInfo.zero
          #expect(info.hasNotch == false)
          #expect(info.hasDynamicIsland == false)
          #expect(info.hasRoundedDisplayCorners == false)
          #expect(info.diagonal == 0)
          #expect(info.ppi == 0)
          #expect(info.screenRatio == .zero)
        }
      #endif

      #if os(tvOS)
        @Test func `zero has zero screen ratio on tvOS`() {
          let info = ScreenInfo.zero
          #expect(info.screenRatio == .zero)
        }
      #endif

      #if os(watchOS)
        @Test func `zero has zero diagonal and ppi on watchOS`() {
          let info = ScreenInfo.zero
          #expect(info.diagonal == 0)
          #expect(info.ppi == 0)
          #expect(info.screenRatio == .zero)
        }
      #endif
    }
  #endif

  #if !os(visionOS) && !os(macOS)
    @Suite("ScreenRatio")
    struct ScreenRatioTests {

      @Test func `zero has all zero values`() {
        let ratio = ScreenRatio.zero
        #expect(ratio.width == 0)
        #expect(ratio.height == 0)
      }

      @Test func `equality works`() {
        let a = ScreenRatio(width: 9, height: 19.5)
        let b = ScreenRatio(width: 9, height: 19.5)
        #expect(a == b)
      }

      @Test func `different values are not equal`() {
        let a = ScreenRatio(width: 9, height: 19.5)
        let b = ScreenRatio(width: 9, height: 16)
        #expect(a != b)
      }
    }
  #endif
}
