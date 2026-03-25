#if os(macOS)

  import Testing

  @testable import DeviceInfo

  @Suite("SoftwareUpdateInfo")
  struct SoftwareUpdateInfoTests {

    @Test func `init stores all properties`() {
      let update = SoftwareUpdateInfo(
        id: "MSU_UPDATE_123",
        displayName: "macOS Sequoia 15.4",
        displayVersion: "15.4",
        isMajorUpdate: false,
        productKey: "MSU_UPDATE_123"
      )
      #expect(update.id == "MSU_UPDATE_123")
      #expect(update.displayName == "macOS Sequoia 15.4")
      #expect(update.displayVersion == "15.4")
      #expect(update.isMajorUpdate == false)
      #expect(update.productKey == "MSU_UPDATE_123")
    }

    @Test func `major update flag identifies cross-version updates`() {
      let major = SoftwareUpdateInfo(
        id: "1", displayName: "macOS 16", displayVersion: "16.0",
        isMajorUpdate: true, productKey: "1"
      )
      let minor = SoftwareUpdateInfo(
        id: "2", displayName: "macOS 15.4", displayVersion: "15.4",
        isMajorUpdate: false, productKey: "2"
      )
      #expect(major.isMajorUpdate)
      #expect(!minor.isMajorUpdate)
    }

    @Test func `equatable compares all fields`() {
      let a = SoftwareUpdateInfo(
        id: "MSU_1", displayName: "macOS 15.4", displayVersion: "15.4",
        isMajorUpdate: false, productKey: "MSU_1"
      )
      let b = SoftwareUpdateInfo(
        id: "MSU_1", displayName: "macOS 15.4", displayVersion: "15.4",
        isMajorUpdate: false, productKey: "MSU_1"
      )
      let c = SoftwareUpdateInfo(
        id: "MSU_2", displayName: "macOS 16.0", displayVersion: "16.0",
        isMajorUpdate: true, productKey: "MSU_2"
      )
      #expect(a == b)
      #expect(a != c)
    }

    @Test func `id conforms to Identifiable`() {
      let update = SoftwareUpdateInfo(
        id: "unique-key", displayName: "Update", displayVersion: "1.0",
        isMajorUpdate: false, productKey: "unique-key"
      )
      #expect(update.id == "unique-key")
    }

    @Test func `identifiable uses productKey as id`() {
      let update = SoftwareUpdateInfo(
        id: "KEY_123", displayName: "macOS 15.4", displayVersion: "15.4", isMajorUpdate: false,
        productKey: "KEY_123")
      #expect(update.id == update.productKey)
    }
  }

#endif
