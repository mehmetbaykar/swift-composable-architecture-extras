import Dependencies
import Foundation

public struct DeviceInfoClient: Sendable {
  public var identity: @Sendable () async -> DeviceIdentity
  public var cpu: @Sendable () async -> CPUInfo
  public var memory: @Sendable () -> MemoryInfo
  public var disk: @Sendable () -> DiskInfo
  public var thermalState: @Sendable () -> DeviceThermalState
  public var isLowPowerModeEnabled: @Sendable () -> Bool

  #if !os(tvOS)
    public var battery: @Sendable () async -> BatteryInfo
  #endif

  #if !os(watchOS)
    public var network: @Sendable () async -> NetworkInfo
  #endif

  #if os(iOS)
    public var jailbreakStatus: @Sendable () async -> JailbreakStatus
  #endif

  #if !os(visionOS)
    public var screen: @Sendable () async -> ScreenInfo
  #endif

  #if os(iOS)
    public init(
      identity: @escaping @Sendable () async -> DeviceIdentity,
      cpu: @escaping @Sendable () async -> CPUInfo,
      memory: @escaping @Sendable () -> MemoryInfo,
      disk: @escaping @Sendable () -> DiskInfo,
      thermalState: @escaping @Sendable () -> DeviceThermalState,
      isLowPowerModeEnabled: @escaping @Sendable () -> Bool,
      battery: @escaping @Sendable () async -> BatteryInfo,
      network: @escaping @Sendable () async -> NetworkInfo,
      jailbreakStatus: @escaping @Sendable () async -> JailbreakStatus,
      screen: @escaping @Sendable () async -> ScreenInfo
    ) {
      self.identity = identity
      self.cpu = cpu
      self.memory = memory
      self.disk = disk
      self.thermalState = thermalState
      self.isLowPowerModeEnabled = isLowPowerModeEnabled
      self.battery = battery
      self.network = network
      self.jailbreakStatus = jailbreakStatus
      self.screen = screen
    }
  #elseif os(visionOS)
    public init(
      identity: @escaping @Sendable () async -> DeviceIdentity,
      cpu: @escaping @Sendable () async -> CPUInfo,
      memory: @escaping @Sendable () -> MemoryInfo,
      disk: @escaping @Sendable () -> DiskInfo,
      thermalState: @escaping @Sendable () -> DeviceThermalState,
      isLowPowerModeEnabled: @escaping @Sendable () -> Bool,
      battery: @escaping @Sendable () async -> BatteryInfo,
      network: @escaping @Sendable () async -> NetworkInfo
    ) {
      self.identity = identity
      self.cpu = cpu
      self.memory = memory
      self.disk = disk
      self.thermalState = thermalState
      self.isLowPowerModeEnabled = isLowPowerModeEnabled
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
      isLowPowerModeEnabled: @escaping @Sendable () -> Bool,
      battery: @escaping @Sendable () async -> BatteryInfo,
      network: @escaping @Sendable () async -> NetworkInfo,
      screen: @escaping @Sendable () async -> ScreenInfo
    ) {
      self.identity = identity
      self.cpu = cpu
      self.memory = memory
      self.disk = disk
      self.thermalState = thermalState
      self.isLowPowerModeEnabled = isLowPowerModeEnabled
      self.battery = battery
      self.network = network
      self.screen = screen
    }
  #elseif os(tvOS)
    public init(
      identity: @escaping @Sendable () async -> DeviceIdentity,
      cpu: @escaping @Sendable () async -> CPUInfo,
      memory: @escaping @Sendable () -> MemoryInfo,
      disk: @escaping @Sendable () -> DiskInfo,
      thermalState: @escaping @Sendable () -> DeviceThermalState,
      isLowPowerModeEnabled: @escaping @Sendable () -> Bool,
      network: @escaping @Sendable () async -> NetworkInfo,
      screen: @escaping @Sendable () async -> ScreenInfo
    ) {
      self.identity = identity
      self.cpu = cpu
      self.memory = memory
      self.disk = disk
      self.thermalState = thermalState
      self.isLowPowerModeEnabled = isLowPowerModeEnabled
      self.network = network
      self.screen = screen
    }
  #elseif os(watchOS)
    public init(
      identity: @escaping @Sendable () async -> DeviceIdentity,
      cpu: @escaping @Sendable () async -> CPUInfo,
      memory: @escaping @Sendable () -> MemoryInfo,
      disk: @escaping @Sendable () -> DiskInfo,
      thermalState: @escaping @Sendable () -> DeviceThermalState,
      isLowPowerModeEnabled: @escaping @Sendable () -> Bool,
      battery: @escaping @Sendable () async -> BatteryInfo,
      screen: @escaping @Sendable () async -> ScreenInfo
    ) {
      self.identity = identity
      self.cpu = cpu
      self.memory = memory
      self.disk = disk
      self.thermalState = thermalState
      self.isLowPowerModeEnabled = isLowPowerModeEnabled
      self.battery = battery
      self.screen = screen
    }
  #endif
}

extension DeviceInfoClient: TestDependencyKey {
  public static var previewValue: DeviceInfoClient { .noop }
  public static var testValue: DeviceInfoClient { .noop }

  public static var noop: DeviceInfoClient {
    #if os(iOS)
      .init(
        identity: { .empty },
        cpu: { .zero },
        memory: { .zero },
        disk: { .zero },
        thermalState: { .nominal },
        isLowPowerModeEnabled: { false },
        battery: { .zero },
        network: { .disconnected },
        jailbreakStatus: { .nominal },
        screen: { .zero }
      )
    #elseif os(visionOS)
      .init(
        identity: { .empty },
        cpu: { .zero },
        memory: { .zero },
        disk: { .zero },
        thermalState: { .nominal },
        isLowPowerModeEnabled: { false },
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
        isLowPowerModeEnabled: { false },
        battery: { .zero },
        network: { .disconnected },
        screen: { .zero }
      )
    #elseif os(tvOS)
      .init(
        identity: { .empty },
        cpu: { .zero },
        memory: { .zero },
        disk: { .zero },
        thermalState: { .nominal },
        isLowPowerModeEnabled: { false },
        network: { .disconnected },
        screen: { .zero }
      )
    #elseif os(watchOS)
      .init(
        identity: { .empty },
        cpu: { .zero },
        memory: { .zero },
        disk: { .zero },
        thermalState: { .nominal },
        isLowPowerModeEnabled: { false },
        battery: { .zero },
        screen: { .zero }
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
