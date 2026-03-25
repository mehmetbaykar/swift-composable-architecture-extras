import Testing

@testable import DeviceInfo

@Suite("DeviceIdentity Extended")
struct DeviceIdentityExtendedTests {

  #if os(macOS)
    @Test func `macOSVersionName returns Sequoia for version 15`() {
      let identity = DeviceIdentity(
        name: "Mac", model: "Mac16,1", systemName: "macOS",
        systemVersion: "15.4", totalCoreCount: 8, activeCoreCount: 8, isiOSAppOnMac: false
      )
      #expect(identity.macOSVersionName == "Sequoia")
    }

    @Test func `macOSVersionName returns Ventura for version 13`() {
      let identity = DeviceIdentity(
        name: "Mac", model: "Mac16,1", systemName: "macOS",
        systemVersion: "13.0", totalCoreCount: 8, activeCoreCount: 8, isiOSAppOnMac: false
      )
      #expect(identity.macOSVersionName == "Ventura")
    }

    @Test func `macOSVersionName returns Sonoma for version 14`() {
      let identity = DeviceIdentity(
        name: "Mac", model: "Mac16,1", systemName: "macOS",
        systemVersion: "14.0", totalCoreCount: 8, activeCoreCount: 8, isiOSAppOnMac: false
      )
      #expect(identity.macOSVersionName == "Sonoma")
    }

    @Test func `macOSVersionName returns Monterey for version 12`() {
      let identity = DeviceIdentity(
        name: "Mac", model: "Mac16,1", systemName: "macOS",
        systemVersion: "12.0", totalCoreCount: 8, activeCoreCount: 8, isiOSAppOnMac: false
      )
      #expect(identity.macOSVersionName == "Monterey")
    }

    @Test func `macOSVersionName returns Big Sur for version 11`() {
      let identity = DeviceIdentity(
        name: "Mac", model: "Mac16,1", systemName: "macOS",
        systemVersion: "11.0", totalCoreCount: 8, activeCoreCount: 8, isiOSAppOnMac: false
      )
      #expect(identity.macOSVersionName == "Big Sur")
    }

    @Test func `macOSVersionName returns Tahoe for version 16`() {
      let identity = DeviceIdentity(
        name: "Mac", model: "Mac16,1", systemName: "macOS",
        systemVersion: "16.0", totalCoreCount: 8, activeCoreCount: 8, isiOSAppOnMac: false
      )
      #expect(identity.macOSVersionName == "Tahoe")
    }

    @Test func `macOSVersionName returns nil for unknown version`() {
      let identity = DeviceIdentity(
        name: "Mac", model: "Mac16,1", systemName: "macOS",
        systemVersion: "99.0", totalCoreCount: 8, activeCoreCount: 8, isiOSAppOnMac: false
      )
      #expect(identity.macOSVersionName == nil)
    }

    @Test func `macOSVersionName returns nil for empty system version`() {
      let identity = DeviceIdentity(
        name: "Mac", model: "Mac16,1", systemName: "macOS",
        systemVersion: "", totalCoreCount: 8, activeCoreCount: 8, isiOSAppOnMac: false
      )
      #expect(identity.macOSVersionName == nil)
    }

    @Test func `macOSVersionName handles version with patch number`() {
      let identity = DeviceIdentity(
        name: "Mac", model: "Mac16,1", systemName: "macOS",
        systemVersion: "15.4.1", totalCoreCount: 8, activeCoreCount: 8, isiOSAppOnMac: false
      )
      #expect(identity.macOSVersionName == "Sequoia")
    }

    @Test func `macOSVersionName handles version 10 returns nil`() {
      let identity = DeviceIdentity(
        name: "Mac", model: "Mac16,1", systemName: "macOS",
        systemVersion: "10.15.7", totalCoreCount: 8, activeCoreCount: 8, isiOSAppOnMac: false
      )
      #expect(identity.macOSVersionName == nil)
    }
  #endif

}
