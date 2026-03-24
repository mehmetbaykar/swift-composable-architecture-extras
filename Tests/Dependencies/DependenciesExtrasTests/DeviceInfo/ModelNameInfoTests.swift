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
  }

#endif
