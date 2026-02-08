#if !os(watchOS)

  import Network

  enum NetworkMeasurement {
    static func measure() async -> NetworkInfo {
      let path = await withCheckedContinuation { continuation in
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
          monitor.cancel()
          continuation.resume(returning: path)
        }
        monitor.start(queue: DispatchQueue(label: "com.deviceinfo.network-check"))
      }

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
