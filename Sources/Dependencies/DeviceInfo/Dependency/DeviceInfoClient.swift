import Dependencies
import Foundation

public struct DeviceInfoClient: Sendable {
  public var identity: @Sendable () async -> DeviceIdentity
  public var cpu: @Sendable () async -> CPUInfo
  public var memory: @Sendable () -> MemoryInfo
  public var disk: @Sendable () -> DiskInfo
  public var thermalState: @Sendable () -> DeviceThermalState

  #if !os(tvOS)
    public var battery: @Sendable () async -> BatteryInfo
  #endif

  #if !os(watchOS)
    public var network: @Sendable () async -> NetworkInfo
  #endif

  #if os(iOS) || os(visionOS)
    public init(
      identity: @escaping @Sendable () async -> DeviceIdentity,
      cpu: @escaping @Sendable () async -> CPUInfo,
      memory: @escaping @Sendable () -> MemoryInfo,
      disk: @escaping @Sendable () -> DiskInfo,
      thermalState: @escaping @Sendable () -> DeviceThermalState,
      battery: @escaping @Sendable () async -> BatteryInfo,
      network: @escaping @Sendable () async -> NetworkInfo
    ) {
      self.identity = identity
      self.cpu = cpu
      self.memory = memory
      self.disk = disk
      self.thermalState = thermalState
      self.battery = battery
      self.network = network
    }
  #elseif os(macOS)
    public init(
      identity: @escaping @Sendable () async -> DeviceIdentity,
      cpu: @escaping @Sendable () async -> CPUInfo,
      memory: @escaping @Sendable () -> MemoryInfo,
      disk: @escaping @Sendable () -> DiskInfo,
      thermalState: @escaping @Sendable () -> DeviceThermalState,
      battery: @escaping @Sendable () async -> BatteryInfo,
      network: @escaping @Sendable () async -> NetworkInfo
    ) {
      self.identity = identity
      self.cpu = cpu
      self.memory = memory
      self.disk = disk
      self.thermalState = thermalState
      self.battery = battery
      self.network = network
    }
  #elseif os(tvOS)
    public init(
      identity: @escaping @Sendable () async -> DeviceIdentity,
      cpu: @escaping @Sendable () async -> CPUInfo,
      memory: @escaping @Sendable () -> MemoryInfo,
      disk: @escaping @Sendable () -> DiskInfo,
      thermalState: @escaping @Sendable () -> DeviceThermalState,
      network: @escaping @Sendable () async -> NetworkInfo
    ) {
      self.identity = identity
      self.cpu = cpu
      self.memory = memory
      self.disk = disk
      self.thermalState = thermalState
      self.network = network
    }
  #elseif os(watchOS)
    public init(
      identity: @escaping @Sendable () async -> DeviceIdentity,
      cpu: @escaping @Sendable () async -> CPUInfo,
      memory: @escaping @Sendable () -> MemoryInfo,
      disk: @escaping @Sendable () -> DiskInfo,
      thermalState: @escaping @Sendable () -> DeviceThermalState,
      battery: @escaping @Sendable () async -> BatteryInfo
    ) {
      self.identity = identity
      self.cpu = cpu
      self.memory = memory
      self.disk = disk
      self.thermalState = thermalState
      self.battery = battery
    }
  #endif
}

extension DeviceInfoClient: TestDependencyKey {
  public static var previewValue: DeviceInfoClient { .noop }
  public static var testValue: DeviceInfoClient { .noop }

  public static var noop: DeviceInfoClient {
    #if os(iOS) || os(visionOS)
      .init(
        identity: { .empty },
        cpu: { .zero },
        memory: { .zero },
        disk: { .zero },
        thermalState: { .nominal },
        battery: { .zero },
        network: { .disconnected }
      )
    #elseif os(macOS)
      .init(
        identity: { .empty },
        cpu: { .zero },
        memory: { .zero },
        disk: { .zero },
        thermalState: { .nominal },
        battery: { .zero },
        network: { .disconnected }
      )
    #elseif os(tvOS)
      .init(
        identity: { .empty },
        cpu: { .zero },
        memory: { .zero },
        disk: { .zero },
        thermalState: { .nominal },
        network: { .disconnected }
      )
    #elseif os(watchOS)
      .init(
        identity: { .empty },
        cpu: { .zero },
        memory: { .zero },
        disk: { .zero },
        thermalState: { .nominal },
        battery: { .zero }
      )
    #endif
  }
}

extension DependencyValues {
  public var deviceInfo: DeviceInfoClient {
    get { self[DeviceInfoClient.self] }
    set { self[DeviceInfoClient.self] = newValue }
  }
}
