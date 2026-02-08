import Testing

@testable import DeviceInfo

@Suite("ByteCount")
struct DeviceInfoByteCountTests {

  @Test func `zero returns 0 bytes`() {
    let count = ByteCount.zero
    #expect(count.bytes == 0)
  }

  @Test func `equality works for same byte values`() {
    let a = ByteCount(bytes: 1024)
    let b = ByteCount(bytes: 1024)
    #expect(a == b)
  }

  @Test func `inequality works for different byte values`() {
    let a = ByteCount(bytes: 1024)
    let b = ByteCount(bytes: 2048)
    #expect(a != b)
  }

  @Test func `formatted produces human-readable string`() {
    let count = ByteCount(bytes: 0)
    #expect(count.formatted.isEmpty == false)
  }

  @Test func `description matches formatted`() {
    let count = ByteCount(bytes: 1_000_000)
    #expect(count.description == count.formatted)
  }

  @Test func `large byte values produce non-empty formatted strings`() {
    let gb = ByteCount(bytes: 4_100_000_000)
    #expect(gb.formatted.isEmpty == false)
  }
}
