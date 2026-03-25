import Dependencies
import Foundation
import Testing

@testable import DeviceInfo

@Suite("DeviceInfo Extended Properties")
struct DeviceInfoExtendedTests {

  @Suite("Noop")
  struct NoopTests {

    @Test func `noop hostname returns empty string`() async {
      let client = DeviceInfoClient.noop
      #expect(await client.hostname() == "")
    }

    @Test func `noop bootTime returns distant past`() {
      let client = DeviceInfoClient.noop
      #expect(client.bootTime() == .distantPast)
    }

    @Test func `noop systemUptime returns zero`() {
      let client = DeviceInfoClient.noop
      #expect(client.systemUptime() == 0)
    }

    #if os(macOS)
      @Test func `noop serialNumber returns empty string`() {
        let client = DeviceInfoClient.noop
        #expect(client.serialNumber() == "")
      }

      @Test func `noop modelName returns unknown`() async {
        let client = DeviceInfoClient.noop
        let model = await client.modelName()
        #expect(model == .unknown)
      }

      @Test func `noop softwareUpdates returns empty array`() {
        let client = DeviceInfoClient.noop
        #expect(client.softwareUpdates().isEmpty)
      }

      @Test func `noop passwordExpiryDays returns nil`() async {
        let client = DeviceInfoClient.noop
        let days = await client.passwordExpiryDays()
        #expect(days == nil)
      }

      @Test func `noop ssid returns nil`() async {
        let client = DeviceInfoClient.noop
        let ssid = await client.ssid()
        #expect(ssid == nil)
      }
    #endif

    #if os(iOS) || os(tvOS) || os(visionOS) || os(watchOS)
      @Test func `noop identifierForVendor returns nil`() async {
        let client = DeviceInfoClient.noop
        let id = await client.identifierForVendor()
        #expect(id == nil)
      }
    #endif
  }

  @Suite("WithDependencies")
  struct WithDependenciesTests {

    @Test func `overridden hostname returns custom value`() async {
      await withDependencies {
        $0.deviceInfo.hostname = { "Test-Device" }
      } operation: {
        @Dependency(\.deviceInfo) var deviceInfo
        #expect(await deviceInfo.hostname() == "Test-Device")
      }
    }

    @Test func `overridden bootTime returns custom value`() {
      let expectedDate = Date(timeIntervalSince1970: 1_000_000)
      withDependencies {
        $0.deviceInfo.bootTime = { expectedDate }
      } operation: {
        @Dependency(\.deviceInfo) var deviceInfo
        #expect(deviceInfo.bootTime() == expectedDate)
      }
    }

    @Test func `overridden systemUptime returns custom value`() {
      withDependencies {
        $0.deviceInfo.systemUptime = { 3600 }
      } operation: {
        @Dependency(\.deviceInfo) var deviceInfo
        #expect(deviceInfo.systemUptime() == 3600)
      }
    }

    #if os(macOS)
      @Test func `overridden serialNumber returns custom value`() {
        withDependencies {
          $0.deviceInfo.serialNumber = { "C02XG1234567" }
        } operation: {
          @Dependency(\.deviceInfo) var deviceInfo
          #expect(deviceInfo.serialNumber() == "C02XG1234567")
        }
      }

      @Test func `overridden modelName returns custom value`() async {
        let expected = ModelNameInfo(
          modelIdentifier: "Mac16,1",
          marketingName: "MacBook Pro (16-inch)",
          shortName: "MacBook Pro",
          year: nil,
          iconSymbolName: "laptopcomputer"
        )
        await withDependencies {
          $0.deviceInfo.modelName = { expected }
        } operation: {
          @Dependency(\.deviceInfo) var deviceInfo
          let result = await deviceInfo.modelName()
          #expect(result == expected)
        }
      }

      @Test func `overridden softwareUpdates returns custom value`() {
        let updates = [
          SoftwareUpdateInfo(
            id: "MSU_123",
            displayName: "macOS Sequoia 15.4",
            displayVersion: "15.4",
            isMajorUpdate: false,
            productKey: "MSU_123"
          )
        ]
        withDependencies {
          $0.deviceInfo.softwareUpdates = { updates }
        } operation: {
          @Dependency(\.deviceInfo) var deviceInfo
          let result = deviceInfo.softwareUpdates()
          #expect(result.count == 1)
          #expect(result.first?.displayName == "macOS Sequoia 15.4")
        }
      }

      @Test func `overridden passwordExpiryDays returns custom value`() async {
        await withDependencies {
          $0.deviceInfo.passwordExpiryDays = { 30 }
        } operation: {
          @Dependency(\.deviceInfo) var deviceInfo
          let days = await deviceInfo.passwordExpiryDays()
          #expect(days == 30)
        }
      }

      @Test func `overridden ssid returns custom value`() async {
        await withDependencies {
          $0.deviceInfo.ssid = { "HomeNetwork" }
        } operation: {
          @Dependency(\.deviceInfo) var deviceInfo
          let ssid = await deviceInfo.ssid()
          #expect(ssid == "HomeNetwork")
        }
      }
    #endif

    #if os(iOS) || os(tvOS) || os(visionOS) || os(watchOS)
      @Test func `overridden identifierForVendor returns custom value`() async {
        let expected = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")
        await withDependencies {
          $0.deviceInfo.identifierForVendor = { expected }
        } operation: {
          @Dependency(\.deviceInfo) var deviceInfo
          let id = await deviceInfo.identifierForVendor()
          #expect(id == expected)
        }
      }
    #endif
  }
}
