import Dependencies
import Foundation

public struct DeviceInfoClient: Sendable {
  /// A snapshot of the device's identity metadata.
  public var identity: @Sendable () async -> DeviceIdentity

  /// A snapshot of CPU usage, measured over a brief sampling interval.
  public var cpu: @Sendable () async -> CPUInfo

  /// A snapshot of the device's physical and used memory.
  public var memory: @Sendable () -> MemoryInfo

  /// A snapshot of disk capacity and usage.
  public var disk: @Sendable () -> DiskInfo

  /// The current thermal state of the device.
  public var thermalState: @Sendable () -> DeviceThermalState

  /// Whether Low Power Mode is currently enabled.
  public var isLowPowerModeEnabled: @Sendable () -> Bool

  /// The user-assigned device name.
  ///
  /// - macOS: `Host.current().localizedName`
  /// - iOS/tvOS: `UIDevice.current.name` (returns generic name on iOS 16+ without entitlement)
  /// - watchOS: `WKInterfaceDevice.current().name`
  public var hostname: @Sendable () -> String

  /// The date when the device was last booted.
  ///
  /// Uses `sysctl` with `CTL_KERN` + `KERN_BOOTTIME` on all platforms.
  public var bootTime: @Sendable () -> Date

  /// Seconds the device has been awake since last wake (sleep time excluded).
  ///
  /// Uses `ProcessInfo.processInfo.systemUptime`.
  public var systemUptime: @Sendable () -> TimeInterval

  #if !os(tvOS)
    /// A snapshot of the device's battery state and charge level.
    public var battery: @Sendable () async -> BatteryInfo
  #endif

  #if !os(watchOS)
    /// A snapshot of the device's network connectivity.
    public var network: @Sendable () async -> NetworkInfo
  #endif

  #if os(iOS)
    /// The jailbreak status of the device, assessed via multiple detection vectors.
    public var jailbreakStatus: @Sendable () async -> JailbreakStatus
  #endif

  #if !os(visionOS)
    /// A snapshot of the device's screen properties.
    public var screen: @Sendable () async -> ScreenInfo
  #endif

  #if os(iOS) || os(tvOS) || os(visionOS)
    /// A UUID unique to the combination of device and vendor.
    ///
    /// Resets when all apps from the same vendor are deleted. Returns `nil`
    /// before first device unlock after restart.
    public var identifierForVendor: @Sendable () -> UUID?
  #elseif os(watchOS)
    /// A UUID unique to the combination of device and vendor.
    ///
    /// Available on watchOS 6.2+. Same semantics as iOS `identifierForVendor`.
    public var identifierForVendor: @Sendable () -> UUID?
  #endif

  #if os(macOS)
    /// The hardware serial number of this Mac.
    ///
    /// Uses IOKit `IOPlatformExpertDevice` to read `kIOPlatformSerialNumberKey`.
    public var serialNumber: @Sendable () -> String

    /// The marketing name and metadata for this Mac model.
    ///
    /// Resolved locally via `ioreg` on Apple Silicon, or via Apple's
    /// `support-sp.apple.com` API on Intel Macs. Cached in memory after first call.
    public var modelName: @Sendable () async -> ModelNameInfo

    /// Pending macOS software updates from the `com.apple.SoftwareUpdate` domain.
    public var softwareUpdates: @Sendable () -> [SoftwareUpdateInfo]

    /// Days until the local macOS user account password expires.
    ///
    /// Uses OpenDirectory `ODRecord.secondsUntilPasswordExpires`. Returns `nil`
    /// if no password policy is configured.
    public var passwordExpiryDays: @Sendable () async -> Int?

    /// The SSID of the currently connected Wi-Fi network.
    ///
    /// Uses CoreWLAN on macOS. Requires Location Services permission on macOS 14+.
    /// Returns `nil` if not connected to Wi-Fi or permission not granted.
    public var ssid: @Sendable () async -> String?
  #endif

  #if os(iOS)
    public init(
      identity: @escaping @Sendable () async -> DeviceIdentity,
      cpu: @escaping @Sendable () async -> CPUInfo,
      memory: @escaping @Sendable () -> MemoryInfo,
      disk: @escaping @Sendable () -> DiskInfo,
      thermalState: @escaping @Sendable () -> DeviceThermalState,
      isLowPowerModeEnabled: @escaping @Sendable () -> Bool,
      hostname: @escaping @Sendable () -> String,
      bootTime: @escaping @Sendable () -> Date,
      systemUptime: @escaping @Sendable () -> TimeInterval,
      battery: @escaping @Sendable () async -> BatteryInfo,
      network: @escaping @Sendable () async -> NetworkInfo,
      jailbreakStatus: @escaping @Sendable () async -> JailbreakStatus,
      screen: @escaping @Sendable () async -> ScreenInfo,
      identifierForVendor: @escaping @Sendable () -> UUID?
    ) {
      self.identity = identity
      self.cpu = cpu
      self.memory = memory
      self.disk = disk
      self.thermalState = thermalState
      self.isLowPowerModeEnabled = isLowPowerModeEnabled
      self.hostname = hostname
      self.bootTime = bootTime
      self.systemUptime = systemUptime
      self.battery = battery
      self.network = network
      self.jailbreakStatus = jailbreakStatus
      self.screen = screen
      self.identifierForVendor = identifierForVendor
    }
  #elseif os(visionOS)
    public init(
      identity: @escaping @Sendable () async -> DeviceIdentity,
      cpu: @escaping @Sendable () async -> CPUInfo,
      memory: @escaping @Sendable () -> MemoryInfo,
      disk: @escaping @Sendable () -> DiskInfo,
      thermalState: @escaping @Sendable () -> DeviceThermalState,
      isLowPowerModeEnabled: @escaping @Sendable () -> Bool,
      hostname: @escaping @Sendable () -> String,
      bootTime: @escaping @Sendable () -> Date,
      systemUptime: @escaping @Sendable () -> TimeInterval,
      battery: @escaping @Sendable () async -> BatteryInfo,
      network: @escaping @Sendable () async -> NetworkInfo,
      identifierForVendor: @escaping @Sendable () -> UUID?
    ) {
      self.identity = identity
      self.cpu = cpu
      self.memory = memory
      self.disk = disk
      self.thermalState = thermalState
      self.isLowPowerModeEnabled = isLowPowerModeEnabled
      self.hostname = hostname
      self.bootTime = bootTime
      self.systemUptime = systemUptime
      self.battery = battery
      self.network = network
      self.identifierForVendor = identifierForVendor
    }
  #elseif os(macOS)
    public init(
      identity: @escaping @Sendable () async -> DeviceIdentity,
      cpu: @escaping @Sendable () async -> CPUInfo,
      memory: @escaping @Sendable () -> MemoryInfo,
      disk: @escaping @Sendable () -> DiskInfo,
      thermalState: @escaping @Sendable () -> DeviceThermalState,
      isLowPowerModeEnabled: @escaping @Sendable () -> Bool,
      hostname: @escaping @Sendable () -> String,
      bootTime: @escaping @Sendable () -> Date,
      systemUptime: @escaping @Sendable () -> TimeInterval,
      battery: @escaping @Sendable () async -> BatteryInfo,
      network: @escaping @Sendable () async -> NetworkInfo,
      screen: @escaping @Sendable () async -> ScreenInfo,
      serialNumber: @escaping @Sendable () -> String,
      modelName: @escaping @Sendable () async -> ModelNameInfo,
      softwareUpdates: @escaping @Sendable () -> [SoftwareUpdateInfo],
      passwordExpiryDays: @escaping @Sendable () async -> Int?,
      ssid: @escaping @Sendable () async -> String?
    ) {
      self.identity = identity
      self.cpu = cpu
      self.memory = memory
      self.disk = disk
      self.thermalState = thermalState
      self.isLowPowerModeEnabled = isLowPowerModeEnabled
      self.hostname = hostname
      self.bootTime = bootTime
      self.systemUptime = systemUptime
      self.battery = battery
      self.network = network
      self.screen = screen
      self.serialNumber = serialNumber
      self.modelName = modelName
      self.softwareUpdates = softwareUpdates
      self.passwordExpiryDays = passwordExpiryDays
      self.ssid = ssid
    }
  #elseif os(tvOS)
    public init(
      identity: @escaping @Sendable () async -> DeviceIdentity,
      cpu: @escaping @Sendable () async -> CPUInfo,
      memory: @escaping @Sendable () -> MemoryInfo,
      disk: @escaping @Sendable () -> DiskInfo,
      thermalState: @escaping @Sendable () -> DeviceThermalState,
      isLowPowerModeEnabled: @escaping @Sendable () -> Bool,
      hostname: @escaping @Sendable () -> String,
      bootTime: @escaping @Sendable () -> Date,
      systemUptime: @escaping @Sendable () -> TimeInterval,
      network: @escaping @Sendable () async -> NetworkInfo,
      screen: @escaping @Sendable () async -> ScreenInfo,
      identifierForVendor: @escaping @Sendable () -> UUID?
    ) {
      self.identity = identity
      self.cpu = cpu
      self.memory = memory
      self.disk = disk
      self.thermalState = thermalState
      self.isLowPowerModeEnabled = isLowPowerModeEnabled
      self.hostname = hostname
      self.bootTime = bootTime
      self.systemUptime = systemUptime
      self.network = network
      self.screen = screen
      self.identifierForVendor = identifierForVendor
    }
  #elseif os(watchOS)
    public init(
      identity: @escaping @Sendable () async -> DeviceIdentity,
      cpu: @escaping @Sendable () async -> CPUInfo,
      memory: @escaping @Sendable () -> MemoryInfo,
      disk: @escaping @Sendable () -> DiskInfo,
      thermalState: @escaping @Sendable () -> DeviceThermalState,
      isLowPowerModeEnabled: @escaping @Sendable () -> Bool,
      hostname: @escaping @Sendable () -> String,
      bootTime: @escaping @Sendable () -> Date,
      systemUptime: @escaping @Sendable () -> TimeInterval,
      battery: @escaping @Sendable () async -> BatteryInfo,
      screen: @escaping @Sendable () async -> ScreenInfo,
      identifierForVendor: @escaping @Sendable () -> UUID?
    ) {
      self.identity = identity
      self.cpu = cpu
      self.memory = memory
      self.disk = disk
      self.thermalState = thermalState
      self.isLowPowerModeEnabled = isLowPowerModeEnabled
      self.hostname = hostname
      self.bootTime = bootTime
      self.systemUptime = systemUptime
      self.battery = battery
      self.screen = screen
      self.identifierForVendor = identifierForVendor
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
        hostname: { "" },
        bootTime: { .distantPast },
        systemUptime: { 0 },
        battery: { .zero },
        network: { .disconnected },
        jailbreakStatus: { .nominal },
        screen: { .zero },
        identifierForVendor: { nil }
      )
    #elseif os(visionOS)
      .init(
        identity: { .empty },
        cpu: { .zero },
        memory: { .zero },
        disk: { .zero },
        thermalState: { .nominal },
        isLowPowerModeEnabled: { false },
        hostname: { "" },
        bootTime: { .distantPast },
        systemUptime: { 0 },
        battery: { .zero },
        network: { .disconnected },
        identifierForVendor: { nil }
      )
    #elseif os(macOS)
      .init(
        identity: { .empty },
        cpu: { .zero },
        memory: { .zero },
        disk: { .zero },
        thermalState: { .nominal },
        isLowPowerModeEnabled: { false },
        hostname: { "" },
        bootTime: { .distantPast },
        systemUptime: { 0 },
        battery: { .zero },
        network: { .disconnected },
        screen: { .zero },
        serialNumber: { "" },
        modelName: { .unknown },
        softwareUpdates: { [] },
        passwordExpiryDays: { nil },
        ssid: { nil }
      )
    #elseif os(tvOS)
      .init(
        identity: { .empty },
        cpu: { .zero },
        memory: { .zero },
        disk: { .zero },
        thermalState: { .nominal },
        isLowPowerModeEnabled: { false },
        hostname: { "" },
        bootTime: { .distantPast },
        systemUptime: { 0 },
        network: { .disconnected },
        screen: { .zero },
        identifierForVendor: { nil }
      )
    #elseif os(watchOS)
      .init(
        identity: { .empty },
        cpu: { .zero },
        memory: { .zero },
        disk: { .zero },
        thermalState: { .nominal },
        isLowPowerModeEnabled: { false },
        hostname: { "" },
        bootTime: { .distantPast },
        systemUptime: { 0 },
        battery: { .zero },
        screen: { .zero },
        identifierForVendor: { nil }
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
