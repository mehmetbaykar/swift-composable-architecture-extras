#if !os(watchOS)

  import Network

  enum NetworkMeasurement {
    static func measure() -> NetworkInfo {
      let monitor = NWPathMonitor()
      let queue = DispatchQueue(label: "com.deviceinfo.network-check")
      monitor.start(queue: queue)
      let path = monitor.currentPath
      monitor.cancel()

      guard path.status == .satisfied else {
        return .disconnected
      }

      let interfaceType: NetworkInterfaceType
      if path.usesInterfaceType(.wifi) {
        interfaceType = .wifi
      } else if path.usesInterfaceType(.cellular) {
        interfaceType = .cellular
      } else if path.usesInterfaceType(.wiredEthernet) {
        interfaceType = .wiredEthernet
      } else if path.usesInterfaceType(.loopback) {
        interfaceType = .loopback
      } else {
        interfaceType = .unknown
      }

      return NetworkInfo(isConnected: true, interfaceType: interfaceType)
    }
  }

#endif
