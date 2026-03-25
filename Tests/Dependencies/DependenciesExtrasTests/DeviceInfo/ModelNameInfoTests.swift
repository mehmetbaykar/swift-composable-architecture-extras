#if os(macOS)

  import Testing

  @testable import DeviceInfo

  @Suite("ModelNameInfo")
  struct ModelNameInfoTests {

    @Test func `unknown has empty values and desktopcomputer icon`() {
      let info = ModelNameInfo.unknown
      #expect(info.modelIdentifier == "")
      #expect(info.marketingName == "")
      #expect(info.shortName == "")
      #expect(info.year == nil)
      #expect(info.iconSymbolName == "desktopcomputer")
    }

    @Test func `init stores all properties`() {
      let info = ModelNameInfo(
        modelIdentifier: "Mac16,1",
        marketingName: "MacBook Pro (16-inch)",
        shortName: "MacBook Pro",
        year: "2024",
        iconSymbolName: "laptopcomputer"
      )
      #expect(info.modelIdentifier == "Mac16,1")
      #expect(info.marketingName == "MacBook Pro (16-inch)")
      #expect(info.shortName == "MacBook Pro")
      #expect(info.year == "2024")
      #expect(info.iconSymbolName == "laptopcomputer")
    }

    @Test func `init with nil year`() {
      let info = ModelNameInfo(
        modelIdentifier: "Mac16,1",
        marketingName: "MacBook Pro",
        shortName: "MacBook Pro",
        year: nil,
        iconSymbolName: "laptopcomputer"
      )
      #expect(info.year == nil)
    }

    @Test func `equatable compares all fields`() {
      let a = ModelNameInfo(
        modelIdentifier: "Mac16,1", marketingName: "MacBook Pro",
        shortName: "MacBook Pro", year: nil, iconSymbolName: "laptopcomputer"
      )
      let b = ModelNameInfo(
        modelIdentifier: "Mac16,1", marketingName: "MacBook Pro",
        shortName: "MacBook Pro", year: nil, iconSymbolName: "laptopcomputer"
      )
      let c = ModelNameInfo(
        modelIdentifier: "Mac16,2", marketingName: "MacBook Pro",
        shortName: "MacBook Pro", year: nil, iconSymbolName: "laptopcomputer"
      )
      #expect(a == b)
      #expect(a != c)
    }

    @Test func `different icon symbol names are not equal`() {
      let a = ModelNameInfo(
        modelIdentifier: "Mac16,1", marketingName: "MacBook Pro",
        shortName: "MacBook Pro", year: nil, iconSymbolName: "laptopcomputer"
      )
      let b = ModelNameInfo(
        modelIdentifier: "Mac16,1", marketingName: "MacBook Pro",
        shortName: "MacBook Pro", year: nil, iconSymbolName: "desktopcomputer"
      )
      #expect(a != b)
    }

    @Test func `MacBook models map to laptopcomputer icon`() {
      let info = ModelNameInfo(
        modelIdentifier: "MacBookPro18,3", marketingName: "MacBook Pro", shortName: "MacBook Pro",
        year: "2021", iconSymbolName: "laptopcomputer")
      #expect(info.iconSymbolName == "laptopcomputer")
    }

    @Test func `Mac mini maps to macmini fill icon`() {
      let info = ModelNameInfo(
        modelIdentifier: "Macmini9,1", marketingName: "Mac mini", shortName: "Mac mini", year: nil,
        iconSymbolName: "macmini.fill")
      #expect(info.iconSymbolName == "macmini.fill")
    }

    @Test func `Mac Pro maps to macpro gen3 icon`() {
      let info = ModelNameInfo(
        modelIdentifier: "MacPro7,1", marketingName: "Mac Pro", shortName: "Mac Pro", year: "2019",
        iconSymbolName: "macpro.gen3")
      #expect(info.iconSymbolName == "macpro.gen3")
    }

    @Test func `Mac Studio maps to macstudio fill icon`() {
      let info = ModelNameInfo(
        modelIdentifier: "Mac13,1", marketingName: "Mac Studio", shortName: "Mac Studio", year: nil,
        iconSymbolName: "macstudio.fill")
      #expect(info.iconSymbolName == "macstudio.fill")
    }

    @Test func `virtual machine maps to server rack icon`() {
      let info = ModelNameInfo(
        modelIdentifier: "VirtualMac2,1", marketingName: "Apple Virtual Machine",
        shortName: "Apple Virtual Machine", year: nil, iconSymbolName: "server.rack")
      #expect(info.iconSymbolName == "server.rack")
    }

    @Test func `iMac maps to desktopcomputer icon`() {
      let info = ModelNameInfo(
        modelIdentifier: "iMac21,1", marketingName: "iMac", shortName: "iMac", year: "2021",
        iconSymbolName: "desktopcomputer")
      #expect(info.iconSymbolName == "desktopcomputer")
    }

    @Test func `nil year for Apple Silicon models`() {
      let info = ModelNameInfo(
        modelIdentifier: "Mac16,1", marketingName: "MacBook Pro", shortName: "MacBook Pro",
        year: nil, iconSymbolName: "laptopcomputer")
      #expect(info.year == nil)
    }

    @Test func `year present for Intel models`() {
      let info = ModelNameInfo(
        modelIdentifier: "MacBookPro18,3", marketingName: "MacBook Pro (Late 2021)",
        shortName: "MacBook Pro", year: "2021", iconSymbolName: "laptopcomputer")
      #expect(info.year == "2021")
    }
  }

#endif
