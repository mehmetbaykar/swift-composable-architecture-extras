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
  }

  @Suite("CustomValues")
  @MainActor
  struct CustomValueTests {

    @Test func `custom implementation returns expected values`() async {
      let expectedIdentity = DeviceIdentity(
        name: "Test Device",
        model: "TestModel",
        systemName: "TestOS",
        systemVersion: "1.0"
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

      #if os(iOS) || os(visionOS)
        let client = DeviceInfoClient(
          identity: { expectedIdentity },
          cpu: { expectedCPU },
          memory: { expectedMemory },
          disk: { expectedDisk },
          thermalState: { .serious },
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
          battery: { BatteryInfo(level: Percentage(rawValue: 0.85), state: .charging) },
          network: { NetworkInfo(isConnected: true, interfaceType: .wifi) }
        )
      #elseif os(tvOS)
        let client = DeviceInfoClient(
          identity: { expectedIdentity },
          cpu: { expectedCPU },
          memory: { expectedMemory },
          disk: { expectedDisk },
          thermalState: { .serious },
          network: { NetworkInfo(isConnected: true, interfaceType: .wifi) }
        )
      #elseif os(watchOS)
        let client = DeviceInfoClient(
          identity: { expectedIdentity },
          cpu: { expectedCPU },
          memory: { expectedMemory },
          disk: { expectedDisk },
          thermalState: { .serious },
          battery: { BatteryInfo(level: Percentage(rawValue: 0.85), state: .charging) }
        )
      #endif

      #expect(await client.identity() == expectedIdentity)
      #expect(await client.cpu() == expectedCPU)
      #expect(client.memory() == expectedMemory)
      #expect(client.disk() == expectedDisk)
      #expect(client.thermalState() == .serious)
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
          DeviceIdentity(name: "Custom", model: "M1", systemName: "macOS", systemVersion: "14.0")
        }
      } operation: {
        @Dependency(\.deviceInfo) var deviceInfo
        let identity = await deviceInfo.identity()
        #expect(identity.name == "Custom")
        #expect(identity.model == "M1")
      }
    }
  }
}
