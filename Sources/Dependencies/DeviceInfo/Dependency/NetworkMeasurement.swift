#if !os(watchOS)

  import Darwin
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

      let (primaryIP, interfaces) = enumerateInterfaces()

      return NetworkInfo(
        isConnected: true,
        interfaceType: interfaceType,
        primaryIPAddress: primaryIP,
        interfaces: interfaces
      )
    }

    private static func enumerateInterfaces() -> (String?, [NetworkInterface]) {
      var interfaces: [NetworkInterface] = []
      var primaryIP: String? = nil

      var ifaddr: UnsafeMutablePointer<ifaddrs>?
      guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else { return (nil, []) }
      defer { freeifaddrs(ifaddr) }

      var ptr: UnsafeMutablePointer<ifaddrs>? = firstAddr
      while let addr = ptr {
        defer { ptr = addr.pointee.ifa_next }

        let flags = Int32(addr.pointee.ifa_flags)
        let isUp = (flags & IFF_UP) != 0
        let isRunning = (flags & IFF_RUNNING) != 0
        let isLoopback = (flags & IFF_LOOPBACK) != 0

        guard let sa = addr.pointee.ifa_addr, sa.pointee.sa_family == UInt8(AF_INET) else {
          continue
        }

        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        guard
          getnameinfo(
            sa, socklen_t(sa.pointee.sa_len),
            &hostname, socklen_t(hostname.count),
            nil, 0, NI_NUMERICHOST
          ) == 0
        else { continue }

        let name = String(
          decoding: [UInt8](
            UnsafeBufferPointer(
              start: UnsafeRawPointer(addr.pointee.ifa_name)
                .assumingMemoryBound(to: UInt8.self),
              count: Int(strlen(addr.pointee.ifa_name)))), as: UTF8.self)
        let ip = String(
          decoding: hostname.prefix(while: { $0 != 0 }).map(UInt8.init(bitPattern:)), as: UTF8.self)
        let isActive = isUp && isRunning

        let type: NetworkInterfaceType
        if isLoopback {
          type = .loopback
        } else if name.hasPrefix("en0") {
          type = .wifi
        } else if name.hasPrefix("en") {
          type = .wiredEthernet
        } else if name.hasPrefix("pdp_ip") {
          type = .cellular
        } else {
          type = .unknown
        }

        let iface = NetworkInterface(name: name, ipAddress: ip, type: type, isActive: isActive)
        interfaces.append(iface)

        if primaryIP == nil && isActive && !isLoopback {
          primaryIP = ip
        }
      }

      return (primaryIP, interfaces)
    }
  }

#endif
