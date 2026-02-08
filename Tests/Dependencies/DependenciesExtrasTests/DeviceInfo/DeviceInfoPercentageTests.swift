import Testing

@testable import DeviceInfo

@Suite("Percentage")
struct DeviceInfoPercentageTests {

  @Test func `zero returns 0 percent`() {
    let pct = Percentage.zero
    #expect(pct.rawValue == 0)
    #expect(pct.value == 0)
  }

  @Test func `value converts rawValue to 0-100 range`() {
    let pct = Percentage(rawValue: 0.421)
    #expect(pct.value >= 42.0)
    #expect(pct.value <= 42.2)
  }

  @Test func `clamps negative values to zero`() {
    let pct = Percentage(rawValue: -0.5)
    #expect(pct.value == 0)
  }

  @Test func `clamps values above 1 to 100`() {
    let pct = Percentage(rawValue: 1.5)
    #expect(pct.value == 100)
  }

  @Test func `formatted produces percent string`() {
    let pct = Percentage(rawValue: 0.5)
    #expect(pct.formatted.contains("50"))
    #expect(pct.formatted.contains("%"))
  }

  @Test func `description matches formatted`() {
    let pct = Percentage(rawValue: 0.75)
    #expect(pct.description == pct.formatted)
  }

  @Test func `equality works`() {
    let a = Percentage(rawValue: 0.5)
    let b = Percentage(rawValue: 0.5)
    #expect(a == b)
  }
}
