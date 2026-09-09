import Darwin
import Dependencies
import Foundation
import Testing

@testable import DeviceInfo

@Suite("DeviceInfo System Services Parity")
struct DeviceInfoSystemServicesTests {

  @Suite("LocalizationInfo")
  struct LocalizationInfoTests {
    @Test func `empty has blank fields`() {
      let info = LocalizationInfo.empty
      #expect(info.localeIdentifier.isEmpty)
      #expect(info.languageCode.isEmpty)
      #expect(info.regionCode == nil)
      #expect(info.timeZoneIdentifier.isEmpty)
      #expect(info.currencySymbol.isEmpty)
      #expect(info.currencyCode == nil)
    }

    @Test func `equality works`() {
      let a = LocalizationInfo(
        localeIdentifier: "en_US",
        languageCode: "en-US",
        regionCode: "US",
        timeZoneIdentifier: "America/Los_Angeles",
        currencySymbol: "$",
        currencyCode: "USD"
      )
      let b = LocalizationInfo(
        localeIdentifier: "en_US",
        languageCode: "en-US",
        regionCode: "US",
        timeZoneIdentifier: "America/Los_Angeles",
        currencySymbol: "$",
        currencyCode: "USD"
      )
      #expect(a == b)
    }

    @Test func `measurement returns populated locale fields`() {
      let info = LocalizationMeasurement.measure()
      #expect(!info.localeIdentifier.isEmpty)
      #expect(!info.timeZoneIdentifier.isEmpty)
    }
  }

  @Suite("ProcessMetrics")
  struct ProcessMetricsTests {
    @Test func `zero has empty values`() {
      let metrics = ProcessMetrics.zero
      #expect(metrics.processID == 0)
      #expect(metrics.cpuUsage == .zero)
    }

    @Test func `measurement process ID matches getpid`() {
      let metrics = ProcessMeasurement.measure()
      #expect(metrics.processID == getpid())
      #expect(metrics.cpuUsage.rawValue >= 0)
    }
  }

  @Suite("DebuggerCheck")
  struct DebuggerCheckTests {
    @Test func `is attached is stable for this process`() {
      #expect(DebuggerCheck.isAttached() == DebuggerCheck.isAttached())
    }
  }

  @Suite("HardwareIdentifier")
  struct HardwareIdentifierTests {
    @Test func `model identifier is non-empty`() {
      #expect(!HardwareIdentifier.modelIdentifier().isEmpty)
    }
  }

  #if os(iOS)
    @Suite("CarrierInfo")
    struct CarrierInfoTests {
      @Test func `unknown has nil identifiers`() {
        let info = CarrierInfo.unknown
        #expect(info.name == nil)
        #expect(info.mobileCountryCode == nil)
        #expect(info.mobileNetworkCode == nil)
        #expect(info.isoCountryCode == nil)
        #expect(info.allowsVOIP == false)
        #expect(info.radioAccessTechnology == nil)
      }

      @Test func `equality works`() {
        let a = CarrierInfo(
          name: "Carrier",
          mobileCountryCode: "310",
          mobileNetworkCode: "410",
          isoCountryCode: "us",
          allowsVOIP: true,
          radioAccessTechnology: "LTE"
        )
        let b = CarrierInfo(
          name: "Carrier",
          mobileCountryCode: "310",
          mobileNetworkCode: "410",
          isoCountryCode: "us",
          allowsVOIP: true,
          radioAccessTechnology: "LTE"
        )
        #expect(a == b)
      }
    }

    @Suite("AccessoryInfo")
    struct AccessoryInfoTests {
      @Test func `none has no connections`() {
        let info = AccessoryInfo.none
        #expect(!info.isHeadphonesConnected)
        #expect(info.connectedAccessories.isEmpty)
        #expect(!info.isAnyAccessoryConnected)
      }

      @Test func `headphones count as an accessory`() {
        let info = AccessoryInfo(isHeadphonesConnected: true)
        #expect(info.isAnyAccessoryConnected)
      }

      @Test func `named accessories count as connected`() {
        let info = AccessoryInfo(
          isHeadphonesConnected: false, connectedAccessories: ["Keyboard"])
        #expect(info.isAnyAccessoryConnected)
        #expect(info.connectedAccessories == ["Keyboard"])
      }
    }

    @Suite("HardwareCapabilities")
    struct HardwareCapabilitiesTests {
      @Test func `none has all flags false`() {
        let info = HardwareCapabilities.none
        #expect(!info.isProximitySensorAvailable)
        #expect(!info.isStepCountingAvailable)
        #expect(!info.isDistanceAvailable)
        #expect(!info.isFloorCountingAvailable)
      }
    }

    @Suite("DeviceInterfaceOrientation")
    struct DeviceInterfaceOrientationTests {
      @Test func `all cases are distinct`() {
        let cases: [DeviceInterfaceOrientation] = [
          .unknown, .portrait, .portraitUpsideDown, .landscapeLeft, .landscapeRight,
        ]
        for i in cases.indices {
          for j in cases.indices where i != j {
            #expect(cases[i] != cases[j])
          }
        }
      }
    }
  #endif

  @Suite("Noop")
  struct NoopTests {
    @Test func `noop localization is empty`() {
      #expect(DeviceInfoClient.noop.localization() == .empty)
    }

    @Test func `noop process is zero`() {
      #expect(DeviceInfoClient.noop.process() == .zero)
    }

    @Test func `noop debugger attached is false`() {
      #expect(DeviceInfoClient.noop.isDebuggerAttached() == false)
    }

    #if !os(watchOS)
      @Test func `noop external IP is nil`() async {
        #expect(await DeviceInfoClient.noop.externalIPAddress() == nil)
      }
    #endif

    #if os(iOS)
      @Test func `noop carrier is unknown`() {
        #expect(DeviceInfoClient.noop.carrier() == .unknown)
      }

      @Test func `noop accessories is none`() async {
        #expect(await DeviceInfoClient.noop.accessories() == .none)
      }

      @Test func `noop hardware capabilities is none`() async {
        #expect(await DeviceInfoClient.noop.hardwareCapabilities() == .none)
      }

      @Test func `noop orientation is unknown`() async {
        #expect(await DeviceInfoClient.noop.orientation() == .unknown)
      }
    #endif
  }

  @Suite("WithDependencies")
  struct WithDependenciesTests {
    @Test func `overridden localization returns custom value`() {
      let expected = LocalizationInfo(
        localeIdentifier: "fr_FR",
        languageCode: "fr",
        regionCode: "FR",
        timeZoneIdentifier: "Europe/Paris",
        currencySymbol: "€",
        currencyCode: "EUR"
      )
      withDependencies {
        $0.deviceInfo.localization = { expected }
      } operation: {
        @Dependency(\.deviceInfo) var deviceInfo
        #expect(deviceInfo.localization() == expected)
      }
    }

    @Test func `overridden process returns custom value`() {
      let expected = ProcessMetrics(processID: 42, cpuUsage: Percentage(rawValue: 0.25))
      withDependencies {
        $0.deviceInfo.process = { expected }
      } operation: {
        @Dependency(\.deviceInfo) var deviceInfo
        #expect(deviceInfo.process() == expected)
      }
    }

    @Test func `overridden debugger attached returns custom value`() {
      withDependencies {
        $0.deviceInfo.isDebuggerAttached = { true }
      } operation: {
        @Dependency(\.deviceInfo) var deviceInfo
        #expect(deviceInfo.isDebuggerAttached())
      }
    }

    #if !os(watchOS)
      @Test func `overridden external IP returns custom value`() async {
        await withDependencies {
          $0.deviceInfo.externalIPAddress = { "203.0.113.10" }
        } operation: {
          @Dependency(\.deviceInfo) var deviceInfo
          #expect(await deviceInfo.externalIPAddress() == "203.0.113.10")
        }
      }
    #endif

    #if os(iOS)
      @Test func `overridden carrier returns custom value`() {
        let expected = CarrierInfo(
          name: "TestCarrier",
          mobileCountryCode: "310",
          mobileNetworkCode: "260",
          isoCountryCode: "us",
          allowsVOIP: true,
          radioAccessTechnology: "NR"
        )
        withDependencies {
          $0.deviceInfo.carrier = { expected }
        } operation: {
          @Dependency(\.deviceInfo) var deviceInfo
          #expect(deviceInfo.carrier() == expected)
        }
      }

      @Test func `overridden accessories returns custom value`() async {
        let expected = AccessoryInfo(
          isHeadphonesConnected: true, connectedAccessories: ["Gamepad"])
        await withDependencies {
          $0.deviceInfo.accessories = { expected }
        } operation: {
          @Dependency(\.deviceInfo) var deviceInfo
          #expect(await deviceInfo.accessories() == expected)
        }
      }

      @Test func `overridden hardware capabilities returns custom value`() async {
        let expected = HardwareCapabilities(
          isProximitySensorAvailable: true,
          isStepCountingAvailable: true,
          isDistanceAvailable: true,
          isFloorCountingAvailable: false
        )
        await withDependencies {
          $0.deviceInfo.hardwareCapabilities = { expected }
        } operation: {
          @Dependency(\.deviceInfo) var deviceInfo
          #expect(await deviceInfo.hardwareCapabilities() == expected)
        }
      }

      @Test func `overridden orientation returns custom value`() async {
        await withDependencies {
          $0.deviceInfo.orientation = { .landscapeLeft }
        } operation: {
          @Dependency(\.deviceInfo) var deviceInfo
          #expect(await deviceInfo.orientation() == .landscapeLeft)
        }
      }
    #endif
  }
}
