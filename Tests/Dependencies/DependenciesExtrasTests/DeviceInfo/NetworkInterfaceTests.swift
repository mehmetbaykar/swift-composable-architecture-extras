#if !os(watchOS)

  import Testing

  @testable import DeviceInfo

  @Suite("NetworkInterface")
  struct NetworkInterfaceTests {

    @Test func `init sets id from name`() {
      let iface = NetworkInterface(
        name: "en0", ipAddress: "192.168.1.10", type: .wifi, isActive: true
      )
      #expect(iface.id == "en0")
      #expect(iface.name == "en0")
      #expect(iface.ipAddress == "192.168.1.10")
      #expect(iface.type == .wifi)
      #expect(iface.isActive)
    }

    @Test func `inactive interface has isActive false`() {
      let iface = NetworkInterface(
        name: "en1", ipAddress: "0.0.0.0", type: .wiredEthernet, isActive: false
      )
      #expect(!iface.isActive)
      #expect(iface.type == .wiredEthernet)
    }

    @Test func `equatable compares all fields`() {
      let a = NetworkInterface(
        name: "en0", ipAddress: "10.0.0.1", type: .wifi, isActive: true
      )
      let b = NetworkInterface(
        name: "en0", ipAddress: "10.0.0.1", type: .wifi, isActive: true
      )
      let c = NetworkInterface(
        name: "en1", ipAddress: "10.0.0.2", type: .wiredEthernet, isActive: true
      )
      #expect(a == b)
      #expect(a != c)
    }

    @Test func `cellular interface type`() {
      let iface = NetworkInterface(
        name: "pdp_ip0", ipAddress: "172.16.0.1", type: .cellular, isActive: true
      )
      #expect(iface.type == .cellular)
    }

    @Test func `loopback interface type`() {
      let iface = NetworkInterface(
        name: "lo0", ipAddress: "127.0.0.1", type: .loopback, isActive: true
      )
      #expect(iface.type == .loopback)
    }
  }

  @Suite("NetworkInfo Extended")
  struct NetworkInfoExtendedTests {

    @Test func `default init has nil IP and empty interfaces`() {
      let info = NetworkInfo(isConnected: true, interfaceType: .wifi)
      #expect(info.isConnected)
      #expect(info.interfaceType == .wifi)
      #expect(info.primaryIPAddress == nil)
      #expect(info.interfaces.isEmpty)
    }

    @Test func `init with interfaces preserves all values`() {
      let iface = NetworkInterface(
        name: "en0", ipAddress: "10.0.0.1", type: .wifi, isActive: true
      )
      let info = NetworkInfo(
        isConnected: true, interfaceType: .wifi,
        primaryIPAddress: "10.0.0.1", interfaces: [iface]
      )
      #expect(info.primaryIPAddress == "10.0.0.1")
      #expect(info.interfaces.count == 1)
      #expect(info.interfaces.first?.name == "en0")
    }

    @Test func `disconnected has nil IP and empty interfaces`() {
      let info = NetworkInfo.disconnected
      #expect(!info.isConnected)
      #expect(info.primaryIPAddress == nil)
      #expect(info.interfaces.isEmpty)
    }

    @Test func `multiple interfaces are preserved`() {
      let wifi = NetworkInterface(
        name: "en0", ipAddress: "192.168.1.10", type: .wifi, isActive: true
      )
      let ethernet = NetworkInterface(
        name: "en1", ipAddress: "192.168.1.11", type: .wiredEthernet, isActive: false
      )
      let info = NetworkInfo(
        isConnected: true, interfaceType: .wifi,
        primaryIPAddress: "192.168.1.10", interfaces: [wifi, ethernet]
      )
      #expect(info.interfaces.count == 2)
    }
  }

#endif
