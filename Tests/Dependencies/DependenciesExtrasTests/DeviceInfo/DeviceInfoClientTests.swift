import Dependencies
import Testing

@testable import DeviceInfo

@Suite("DeviceInfoClient")
@MainActor
struct DeviceInfoClientTests {

  @Suite("Noop")
  @MainActor
  struct NoopTests {

    @Test func `noop returns default identity`() async {
      let client = DeviceInfoClient.noop
      let identity = await client.identity()
      #expect(identity == .empty)
    }

    @Test func `noop returns zero CPU info`() async {
      let client = DeviceInfoClient.noop
      let cpu = await client.cpu()
      #expect(cpu == .zero)
    }

    @Test func `noop returns zero memory info`() {
      let client = DeviceInfoClient.noop
      let memory = client.memory()
      #expect(memory == .zero)
    }

    @Test func `noop returns zero disk info`() {
      let client = DeviceInfoClient.noop
      let disk = client.disk()
      #expect(disk == .zero)
    }

    @Test func `noop returns nominal thermal state`() {
      let client = DeviceInfoClient.noop
      let thermal = client.thermalState()
      #expect(thermal == .nominal)
    }

    @Test func `noop returns false for isLowPowerModeEnabled`() {
      let client = DeviceInfoClient.noop
      #expect(client.isLowPowerModeEnabled() == false)
    }

    #if !os(tvOS)
      @Test func `noop returns zero battery info`() async {
        let client = DeviceInfoClient.noop
        let battery = await client.battery()
        #expect(battery == .zero)
      }
    #endif

    #if !os(watchOS)
      @Test func `noop returns disconnected network info`() async {
        let client = DeviceInfoClient.noop
        let network = await client.network()
        #expect(network == .disconnected)
      }
    #endif

    #if os(iOS)
      @Test func `noop returns nominal jailbreak status`() async {
        let client = DeviceInfoClient.noop
        let status = await client.jailbreakStatus()
        #expect(status == .nominal)
      }
    #endif

    #if !os(visionOS)
      @Test func `noop returns zero screen info`() async {
        let client = DeviceInfoClient.noop
        let screen = await client.screen()
        #expect(screen == .zero)
      }
    #endif
  }

  @Suite("CustomValues")
  @MainActor
  struct CustomValueTests {

    @Test func `custom implementation returns expected values`() async {
      let expectedIdentity = DeviceIdentity(
        name: "Test Device",
        model: "TestModel",
        systemName: "TestOS",
        systemVersion: "1.0",
        totalCoreCount: 8,
        activeCoreCount: 8,
        isiOSAppOnMac: false
      )
      let expectedCPU = CPUInfo(
        usage: Percentage(rawValue: 0.5),
        user: Percentage(rawValue: 0.3),
        system: Percentage(rawValue: 0.2),
        idle: Percentage(rawValue: 0.5)
      )
      let expectedMemory = MemoryInfo(
        usage: Percentage(rawValue: 0.75),
        total: ByteCount(bytes: 8_000_000_000),
        used: ByteCount(bytes: 6_000_000_000),
        available: ByteCount(bytes: 2_000_000_000)
      )
      let expectedDisk = DiskInfo(
        usage: Percentage(rawValue: 0.6),
        total: ByteCount(bytes: 500_000_000_000),
        used: ByteCount(bytes: 300_000_000_000),
        available: ByteCount(bytes: 200_000_000_000)
      )

      #if os(iOS)
        let client = DeviceInfoClient(
          identity: { expectedIdentity },
          cpu: { expectedCPU },
          memory: { expectedMemory },
          disk: { expectedDisk },
          thermalState: { .serious },
          isLowPowerModeEnabled: { true },
          battery: { BatteryInfo(level: Percentage(rawValue: 0.85), state: .charging) },
          network: { NetworkInfo(isConnected: true, interfaceType: .wifi) },
          jailbreakStatus: { JailbreakStatus(confidence: .high) },
          screen: { .zero }
        )
      #elseif os(visionOS)
        let client = DeviceInfoClient(
          identity: { expectedIdentity },
          cpu: { expectedCPU },
          memory: { expectedMemory },
          disk: { expectedDisk },
          thermalState: { .serious },
          isLowPowerModeEnabled: { true },
          battery: { BatteryInfo(level: Percentage(rawValue: 0.85), state: .charging) },
          network: { NetworkInfo(isConnected: true, interfaceType: .wifi) }
        )
      #elseif os(macOS)
        let client = DeviceInfoClient(
          identity: { expectedIdentity },
          cpu: { expectedCPU },
          memory: { expectedMemory },
          disk: { expectedDisk },
          thermalState: { .serious },
          isLowPowerModeEnabled: { true },
          battery: { BatteryInfo(level: Percentage(rawValue: 0.85), state: .charging) },
          network: { NetworkInfo(isConnected: true, interfaceType: .wifi) },
          screen: { .zero }
        )
      #elseif os(tvOS)
        let client = DeviceInfoClient(
          identity: { expectedIdentity },
          cpu: { expectedCPU },
          memory: { expectedMemory },
          disk: { expectedDisk },
          thermalState: { .serious },
          isLowPowerModeEnabled: { true },
          network: { NetworkInfo(isConnected: true, interfaceType: .wifi) },
          screen: { .zero }
        )
      #elseif os(watchOS)
        let client = DeviceInfoClient(
          identity: { expectedIdentity },
          cpu: { expectedCPU },
          memory: { expectedMemory },
          disk: { expectedDisk },
          thermalState: { .serious },
          isLowPowerModeEnabled: { true },
          battery: { BatteryInfo(level: Percentage(rawValue: 0.85), state: .charging) },
          screen: { .zero }
        )
      #endif

      #expect(await client.identity() == expectedIdentity)
      #expect(await client.cpu() == expectedCPU)
      #expect(client.memory() == expectedMemory)
      #expect(client.disk() == expectedDisk)
      #expect(client.thermalState() == .serious)
      #expect(client.isLowPowerModeEnabled() == true)

      #if os(iOS)
        #expect(await client.jailbreakStatus() == JailbreakStatus(confidence: .high))
      #endif
    }
  }

  @Suite("WithDependencies")
  @MainActor
  struct WithDependenciesTests {

    @Test func `dependency is accessible via DependencyValues`() async {
      withDependencies {
        $0.deviceInfo = .noop
      } operation: {
        @Dependency(\.deviceInfo) var deviceInfo
        // identity is async but noop returns .empty synchronously
        _ = deviceInfo
      }
    }

    @Test func `overridden identity returns custom values`() async {
      await withDependencies {
        $0.deviceInfo.identity = {
          DeviceIdentity(
            name: "Custom",
            model: "M1",
            systemName: "macOS",
            systemVersion: "14.0",
            totalCoreCount: 8,
            activeCoreCount: 8,
            isiOSAppOnMac: false
          )
        }
      } operation: {
        @Dependency(\.deviceInfo) var deviceInfo
        let identity = await deviceInfo.identity()
        #expect(identity.name == "Custom")
        #expect(identity.model == "M1")
      }
    }

    #if os(iOS)
      @Test func `overridden jailbreakStatus returns custom value`() async {
        await withDependencies {
          $0.deviceInfo.jailbreakStatus = { JailbreakStatus(confidence: .moderate) }
        } operation: {
          @Dependency(\.deviceInfo) var deviceInfo
          let status = await deviceInfo.jailbreakStatus()
          #expect(status.confidence == .moderate)
        }
      }
    #endif

    #if os(iOS)
      @Test func `overridden screen returns custom values`() async {
        let customScreen = ScreenInfo(
          width: 390,
          height: 844,
          scale: 3,
          screenRatio: ScreenRatio(width: 9, height: 19.5),
          diagonal: 6.1,
          ppi: 460,
          hasNotch: false,
          hasDynamicIsland: true,
          hasRoundedDisplayCorners: true
        )
        await withDependencies {
          $0.deviceInfo.screen = { customScreen }
        } operation: {
          @Dependency(\.deviceInfo) var deviceInfo
          let screen = await deviceInfo.screen()
          #expect(screen.width == 390)
          #expect(screen.height == 844)
          #expect(screen.scale == 3)
          #expect(screen.hasDynamicIsland == true)
        }
      }
    #elseif os(macOS)
      @Test func `overridden screen returns custom values`() async {
        let customScreen = ScreenInfo(
          width: 1920,
          height: 1080,
          scale: 2
        )
        await withDependencies {
          $0.deviceInfo.screen = { customScreen }
        } operation: {
          @Dependency(\.deviceInfo) var deviceInfo
          let screen = await deviceInfo.screen()
          #expect(screen.width == 1920)
          #expect(screen.height == 1080)
          #expect(screen.scale == 2)
        }
      }
    #endif
  }

  #if os(iOS)
    @Suite("JailbreakModels")
    @MainActor
    struct JailbreakModelTests {

      @Test func `JailbreakConfidence ordering is correct`() {
        #expect(JailbreakConfidence.nominal < .low)
        #expect(JailbreakConfidence.low < .moderate)
        #expect(JailbreakConfidence.moderate < .high)
        #expect(JailbreakConfidence.nominal < .high)
      }

      @Test func `JailbreakConfidence raw values are sequential`() {
        #expect(JailbreakConfidence.nominal.rawValue == 0)
        #expect(JailbreakConfidence.low.rawValue == 1)
        #expect(JailbreakConfidence.moderate.rawValue == 2)
        #expect(JailbreakConfidence.high.rawValue == 3)
      }

      @Test func `JailbreakStatus nominal static returns correct confidence`() {
        let status = JailbreakStatus.nominal
        #expect(status.confidence == .nominal)
      }

      @Test func `JailbreakStatus equality works correctly`() {
        let a = JailbreakStatus(confidence: .high)
        let b = JailbreakStatus(confidence: .high)
        let c = JailbreakStatus(confidence: .low)
        #expect(a == b)
        #expect(a != c)
      }
    }
  #endif
}
