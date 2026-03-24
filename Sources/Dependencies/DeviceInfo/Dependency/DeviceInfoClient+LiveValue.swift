import Dependencies
import Foundation

#if os(iOS)
  import UIKit

  extension DeviceInfoClient: DependencyKey {
    public static var liveValue: DeviceInfoClient {
      .init(
        identity: {
          await MainActor.run {
            let device = UIDevice.current
            let isiOSAppOnMac: Bool = {
              if #available(iOS 14.0, *) {
                return ProcessInfo.processInfo.isiOSAppOnMac
              }
              return false
            }()
            return DeviceIdentity(
              name: device.name,
              model: device.model,
              systemName: device.systemName,
              systemVersion: device.systemVersion,
              totalCoreCount: ProcessInfo.processInfo.processorCount,
              activeCoreCount: ProcessInfo.processInfo.activeProcessorCount,
              isiOSAppOnMac: isiOSAppOnMac
            )
          }
        },
        cpu: { await CPUMeasurement.measure() },
        memory: { MemoryMeasurement.measure() },
        disk: { DiskMeasurement.measure() },
        thermalState: {
          DeviceThermalState(processInfoState: ProcessInfo.processInfo.thermalState)
        },
        isLowPowerModeEnabled: {
          ProcessInfo.processInfo.isLowPowerModeEnabled
        },
        hostname: {
          ProcessInfo.processInfo.hostName
        },
        bootTime: {
          var mib = [CTL_KERN, KERN_BOOTTIME]
          var bootTime = timeval()
          var size = MemoryLayout<timeval>.size
          if sysctl(&mib, 2, &bootTime, &size, nil, 0) == 0 {
            return Date(timeIntervalSince1970: Double(bootTime.tv_sec))
          }
          return Date(timeIntervalSinceNow: -ProcessInfo.processInfo.systemUptime)
        },
        systemUptime: {
          ProcessInfo.processInfo.systemUptime
        },
        battery: {
          await MainActor.run { BatteryMeasurement.measure() }
        },
        network: { await NetworkMeasurement.measure() },
        jailbreakStatus: { JailbreakMeasurement.measure() },
        screen: { await MainActor.run { ScreenMeasurement.measure() } },
        identifierForVendor: {
          UIDevice.current.identifierForVendor
        }
      )
    }
  }

#elseif os(visionOS)
  import UIKit

  extension DeviceInfoClient: DependencyKey {
    public static var liveValue: DeviceInfoClient {
      .init(
        identity: {
          await MainActor.run {
            let device = UIDevice.current
            return DeviceIdentity(
              name: device.name,
              model: device.model,
              systemName: device.systemName,
              systemVersion: device.systemVersion,
              totalCoreCount: ProcessInfo.processInfo.processorCount,
              activeCoreCount: ProcessInfo.processInfo.activeProcessorCount,
              isiOSAppOnMac: ProcessInfo.processInfo.isiOSAppOnMac
            )
          }
        },
        cpu: { await CPUMeasurement.measure() },
        memory: { MemoryMeasurement.measure() },
        disk: { DiskMeasurement.measure() },
        thermalState: {
          DeviceThermalState(processInfoState: ProcessInfo.processInfo.thermalState)
        },
        isLowPowerModeEnabled: {
          ProcessInfo.processInfo.isLowPowerModeEnabled
        },
        hostname: {
          ProcessInfo.processInfo.hostName
        },
        bootTime: {
          var mib = [CTL_KERN, KERN_BOOTTIME]
          var bootTime = timeval()
          var size = MemoryLayout<timeval>.size
          if sysctl(&mib, 2, &bootTime, &size, nil, 0) == 0 {
            return Date(timeIntervalSince1970: Double(bootTime.tv_sec))
          }
          return Date(timeIntervalSinceNow: -ProcessInfo.processInfo.systemUptime)
        },
        systemUptime: {
          ProcessInfo.processInfo.systemUptime
        },
        battery: {
          await MainActor.run { BatteryMeasurement.measure() }
        },
        network: { await NetworkMeasurement.measure() },
        identifierForVendor: {
          UIDevice.current.identifierForVendor
        }
      )
    }
  }

#elseif os(macOS)
  import CoreWLAN
  import IOKit
  import OpenDirectory

  extension DeviceInfoClient: DependencyKey {
    public static var liveValue: DeviceInfoClient {
      .init(
        identity: {
          let processInfo = ProcessInfo.processInfo
          var systemInfo = utsname()
          uname(&systemInfo)
          let model = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
              String(validatingCString: $0) ?? "Mac"
            }
          }
          let isiOSAppOnMac: Bool = {
            if #available(macOS 11.0, *) {
              return processInfo.isiOSAppOnMac
            }
            return false
          }()
          return DeviceIdentity(
            name: processInfo.hostName,
            model: model,
            systemName: "macOS",
            systemVersion: processInfo.operatingSystemVersionString,
            totalCoreCount: processInfo.processorCount,
            activeCoreCount: processInfo.activeProcessorCount,
            isiOSAppOnMac: isiOSAppOnMac
          )
        },
        cpu: { await CPUMeasurement.measure() },
        memory: { MemoryMeasurement.measure() },
        disk: { DiskMeasurement.measure() },
        thermalState: {
          DeviceThermalState(processInfoState: ProcessInfo.processInfo.thermalState)
        },
        isLowPowerModeEnabled: {
          if #available(macOS 12.0, *) {
            return ProcessInfo.processInfo.isLowPowerModeEnabled
          }
          return false
        },
        hostname: {
          Host.current().localizedName ?? ProcessInfo.processInfo.hostName
        },
        bootTime: {
          var mib = [CTL_KERN, KERN_BOOTTIME]
          var bootTime = timeval()
          var size = MemoryLayout<timeval>.size
          if sysctl(&mib, 2, &bootTime, &size, nil, 0) == 0 {
            return Date(timeIntervalSince1970: Double(bootTime.tv_sec))
          }
          return Date(timeIntervalSinceNow: -ProcessInfo.processInfo.systemUptime)
        },
        systemUptime: {
          ProcessInfo.processInfo.systemUptime
        },
        battery: { BatteryMeasurement.measure() },
        network: { await NetworkMeasurement.measure() },
        screen: { await MainActor.run { ScreenMeasurement.measure() } },
        serialNumber: {
          let platformExpert = IOServiceGetMatchingService(
            kIOMainPortDefault,
            IOServiceMatching("IOPlatformExpertDevice")
          )
          guard platformExpert != 0 else { return "" }
          defer { IOObjectRelease(platformExpert) }
          guard
            let serialNumber = IORegistryEntryCreateCFProperty(
              platformExpert,
              kIOPlatformSerialNumberKey as CFString,
              kCFAllocatorDefault,
              0
            )?.takeRetainedValue() as? String
          else { return "" }
          return serialNumber
        },
        modelName: {
          await ModelNameResolver.shared.resolve()
        },
        softwareUpdates: {
          SoftwareUpdateReader.read()
        },
        passwordExpiryDays: {
          await PasswordExpiryReader.read()
        },
        ssid: {
          await SSIDReader.read()
        }
      )
    }
  }

  private actor ModelNameResolver {
    static let shared = ModelNameResolver()

    private var cached: ModelNameInfo?

    func resolve() async -> ModelNameInfo {
      if let cached {
        return cached
      }
      let info = await resolveFromSystem()
      self.cached = info
      return info
    }

    private func resolveFromSystem() async -> ModelNameInfo {
      var size = 0
      sysctlbyname("hw.model", nil, &size, nil, 0)
      var model = [CChar](repeating: 0, count: size)
      sysctlbyname("hw.model", &model, &size, nil, 0)
      let modelIdentifier = String(
        decoding: model.prefix(while: { $0 != 0 }).map(UInt8.init(bitPattern:)), as: UTF8.self)

      #if arch(arm64)
        return await resolveAppleSilicon(modelIdentifier: modelIdentifier)
      #else
        return await resolveIntel(modelIdentifier: modelIdentifier)
      #endif
    }

    #if arch(arm64)
      private func resolveAppleSilicon(modelIdentifier: String) async -> ModelNameInfo {
        let task = Process()
        let pipe = Pipe()
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.arguments = [
          "-c", "ioreg -c IOPlatformDevice | grep -e 'product-name' | cut -d'\"' -f 4",
        ]
        task.standardOutput = pipe
        task.standardError = pipe

        do {
          try task.run()
          let data = pipe.fileHandleForReading.readDataToEndOfFile()
          task.waitUntilExit()
          let name =
            String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

          let (shortName, icon) = mapNameToShortNameAndIcon(name)
          return ModelNameInfo(
            modelIdentifier: modelIdentifier,
            marketingName: name,
            shortName: shortName,
            year: nil,
            iconSymbolName: icon
          )
        } catch {
          return .unknown
        }
      }
    #else
      private func resolveIntel(modelIdentifier: String) async -> ModelNameInfo {
        let identifierString =
          modelIdentifier
          .components(separatedBy: CharacterSet.decimalDigits).joined()
          .components(separatedBy: CharacterSet.punctuationCharacters).joined()

        let (shortName, icon) = mapIdentifierToShortNameAndIcon(
          identifierString, raw: modelIdentifier)

        let platformExpert = IOServiceGetMatchingService(
          kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
        guard platformExpert != 0 else {
          return ModelNameInfo(
            modelIdentifier: modelIdentifier, marketingName: shortName,
            shortName: shortName, year: nil, iconSymbolName: icon)
        }
        defer { IOObjectRelease(platformExpert) }

        guard
          let serial = IORegistryEntryCreateCFProperty(
            platformExpert, kIOPlatformSerialNumberKey as CFString, kCFAllocatorDefault, 0
          )?.takeRetainedValue() as? String, serial.count >= 4
        else {
          return ModelNameInfo(
            modelIdentifier: modelIdentifier, marketingName: shortName,
            shortName: shortName, year: nil, iconSymbolName: icon)
        }

        let suffix = String(serial.suffix(4))
        guard let url = URL(string: "https://support-sp.apple.com/sp/product?cc=\(suffix)"),
          let data = try? Data(contentsOf: url),
          let response = String(data: data, encoding: .utf8)
        else {
          return ModelNameInfo(
            modelIdentifier: modelIdentifier, marketingName: shortName,
            shortName: shortName, year: nil, iconSymbolName: icon)
        }

        let namePattern = try? NSRegularExpression(pattern: "<configCode>(.+?)</configCode>")
        let yearPattern = try? NSRegularExpression(pattern: "(20[0-9][0-9])")
        let range = NSRange(response.startIndex..., in: response)

        let marketingName =
          namePattern?.firstMatch(in: response, range: range)
          .flatMap { Range($0.range(at: 1), in: response) }
          .map { String(response[$0]) } ?? shortName

        let year =
          yearPattern?.firstMatch(in: response, range: range)
          .flatMap { Range($0.range(at: 1), in: response) }
          .map { String(response[$0]) }

        return ModelNameInfo(
          modelIdentifier: modelIdentifier, marketingName: marketingName,
          shortName: shortName, year: year, iconSymbolName: icon)
      }
    #endif

    private func mapNameToShortNameAndIcon(_ name: String) -> (String, String) {
      if name.localizedCaseInsensitiveContains("MacBook") {
        return ("MacBook", "laptopcomputer")
      }
      if name.localizedCaseInsensitiveContains("Mac mini") {
        return ("Mac mini", "macmini.fill")
      }
      if name.localizedCaseInsensitiveContains("Mac Pro") {
        return ("Mac Pro", "macpro.gen3.fill")
      }
      if name.localizedCaseInsensitiveContains("Mac Studio") {
        return ("Mac Studio", "macstudio.fill")
      }
      if name.localizedCaseInsensitiveContains("Apple Virtual Machine") {
        return ("Apple Virtual Machine", "server.rack")
      }
      if name.localizedCaseInsensitiveContains("iMac") { return ("iMac", "desktopcomputer") }
      return (name, "desktopcomputer")
    }

    private func mapIdentifierToShortNameAndIcon(_ id: String, raw: String) -> (String, String) {
      if id.hasPrefix("MacBookAir") { return ("MacBook Air", "laptopcomputer") }
      if id.hasPrefix("MacBookPro") { return ("MacBook Pro", "laptopcomputer") }
      if id.hasPrefix("MacBook") { return ("MacBook", "laptopcomputer") }
      if id.hasPrefix("Macmini") { return ("Mac mini", "macmini.fill") }
      if id.hasPrefix("MacPro") {
        return raw == "MacPro6,1"
          ? ("Mac Pro", "macpro.gen2.fill")
          : ("Mac Pro", "macpro.gen3")
      }
      if id.hasPrefix("VirtualMac") { return ("Apple Virtual Machine", "server.rack") }
      if id.hasPrefix("iMac") { return ("iMac", "desktopcomputer") }
      return ("Mac", "desktopcomputer")
    }
  }

  private enum SoftwareUpdateReader {
    static func read() -> [SoftwareUpdateInfo] {
      guard
        let updates = UserDefaults(suiteName: "com.apple.SoftwareUpdate")?
          .array(forKey: "RecommendedUpdates") as? [[String: Any]]
      else { return [] }

      let currentMajor = ProcessInfo.processInfo.operatingSystemVersion.majorVersion

      return updates.compactMap { dict in
        guard let displayName = dict["Display Name"] as? String,
          let displayVersion = dict["Display Version"] as? String,
          let productKey = dict["Product Key"] as? String
        else { return nil }

        let updateMajor =
          Int(displayVersion.components(separatedBy: ".").first ?? "") ?? currentMajor

        return SoftwareUpdateInfo(
          id: productKey,
          displayName: displayName,
          displayVersion: displayVersion,
          isMajorUpdate: updateMajor != currentMajor,
          productKey: productKey
        )
      }
    }
  }

  private enum PasswordExpiryReader {
    static func read() async -> Int? {
      guard let session = ODSession.default() else { return nil }
      guard let node = try? ODNode(session: session, type: ODNodeType(kODNodeTypeAuthentication))
      else { return nil }

      let query = try? ODQuery(
        node: node,
        forRecordTypes: kODRecordTypeUsers,
        attribute: kODAttributeTypeRecordName,
        matchType: ODMatchType(kODMatchEqualTo),
        queryValues: NSUserName(),
        returnAttributes: kODAttributeTypeNativeOnly,
        maximumResults: 1
      )

      guard let results = try? query?.resultsAllowingPartial(false) as? [ODRecord],
        let record = results.first
      else { return nil }

      let seconds = record.secondsUntilPasswordExpires
      guard seconds != 0 else { return nil }
      if seconds < 0 { return 0 }
      return Int(seconds / 86400)
    }
  }

  private enum SSIDReader {
    static func read() async -> String? {
      CWWiFiClient.shared().interface()?.ssid()
    }
  }

#elseif os(tvOS)
  import UIKit

  extension DeviceInfoClient: DependencyKey {
    public static var liveValue: DeviceInfoClient {
      .init(
        identity: {
          await MainActor.run {
            let device = UIDevice.current
            let isiOSAppOnMac: Bool = {
              if #available(tvOS 14.0, *) {
                return ProcessInfo.processInfo.isiOSAppOnMac
              }
              return false
            }()
            return DeviceIdentity(
              name: device.name,
              model: device.model,
              systemName: device.systemName,
              systemVersion: device.systemVersion,
              totalCoreCount: ProcessInfo.processInfo.processorCount,
              activeCoreCount: ProcessInfo.processInfo.activeProcessorCount,
              isiOSAppOnMac: isiOSAppOnMac
            )
          }
        },
        cpu: { await CPUMeasurement.measure() },
        memory: { MemoryMeasurement.measure() },
        disk: { DiskMeasurement.measure() },
        thermalState: {
          DeviceThermalState(processInfoState: ProcessInfo.processInfo.thermalState)
        },
        isLowPowerModeEnabled: {
          ProcessInfo.processInfo.isLowPowerModeEnabled
        },
        hostname: {
          ProcessInfo.processInfo.hostName
        },
        bootTime: {
          var mib = [CTL_KERN, KERN_BOOTTIME]
          var bootTime = timeval()
          var size = MemoryLayout<timeval>.size
          if sysctl(&mib, 2, &bootTime, &size, nil, 0) == 0 {
            return Date(timeIntervalSince1970: Double(bootTime.tv_sec))
          }
          return Date(timeIntervalSinceNow: -ProcessInfo.processInfo.systemUptime)
        },
        systemUptime: {
          ProcessInfo.processInfo.systemUptime
        },
        network: { await NetworkMeasurement.measure() },
        screen: { await MainActor.run { ScreenMeasurement.measure() } },
        identifierForVendor: {
          UIDevice.current.identifierForVendor
        }
      )
    }
  }

#elseif os(watchOS)
  import WatchKit

  extension DeviceInfoClient: DependencyKey {
    public static var liveValue: DeviceInfoClient {
      .init(
        identity: {
          await MainActor.run {
            let device = WKInterfaceDevice.current()
            let isiOSAppOnMac: Bool = {
              if #available(watchOS 7.0, *) {
                return ProcessInfo.processInfo.isiOSAppOnMac
              }
              return false
            }()
            return DeviceIdentity(
              name: device.name,
              model: device.model,
              systemName: device.systemName,
              systemVersion: device.systemVersion,
              totalCoreCount: ProcessInfo.processInfo.processorCount,
              activeCoreCount: ProcessInfo.processInfo.activeProcessorCount,
              isiOSAppOnMac: isiOSAppOnMac
            )
          }
        },
        cpu: { await CPUMeasurement.measure() },
        memory: { MemoryMeasurement.measure() },
        disk: { DiskMeasurement.measure() },
        thermalState: {
          DeviceThermalState(processInfoState: ProcessInfo.processInfo.thermalState)
        },
        isLowPowerModeEnabled: {
          ProcessInfo.processInfo.isLowPowerModeEnabled
        },
        hostname: {
          ProcessInfo.processInfo.hostName
        },
        bootTime: {
          var mib = [CTL_KERN, KERN_BOOTTIME]
          var bootTime = timeval()
          var size = MemoryLayout<timeval>.size
          if sysctl(&mib, 2, &bootTime, &size, nil, 0) == 0 {
            return Date(timeIntervalSince1970: Double(bootTime.tv_sec))
          }
          return Date(timeIntervalSinceNow: -ProcessInfo.processInfo.systemUptime)
        },
        systemUptime: {
          ProcessInfo.processInfo.systemUptime
        },
        battery: { BatteryMeasurement.measure() },
        screen: { await MainActor.run { ScreenMeasurement.measure() } },
        identifierForVendor: {
          WKInterfaceDevice.current().identifierForVendor
        }
      )
    }
  }
#endif
