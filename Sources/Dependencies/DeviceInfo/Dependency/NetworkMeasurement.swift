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

    private struct InterfaceBuilder {
      var ipAddress = ""
      var ipv6Address: String?
      var netmask: String?
      var broadcastAddress: String?
      var isActive = false
      var isLoopback = false
    }

    private static func enumerateInterfaces() -> (String?, [NetworkInterface]) {
      var builders: [String: InterfaceBuilder] = [:]

      var ifaddr: UnsafeMutablePointer<ifaddrs>?
      guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else { return (nil, []) }
      defer { freeifaddrs(ifaddr) }

      var ptr: UnsafeMutablePointer<ifaddrs>? = firstAddr
      while let addr = ptr {
        defer { ptr = addr.pointee.ifa_next }

        guard let sa = addr.pointee.ifa_addr else { continue }
        let family = Int32(sa.pointee.sa_family)
        guard family == AF_INET || family == AF_INET6 else { continue }

        let flags = Int32(addr.pointee.ifa_flags)
        let isUp = (flags & IFF_UP) != 0
        let isRunning = (flags & IFF_RUNNING) != 0
        let isLoopback = (flags & IFF_LOOPBACK) != 0
        let name = String(cString: addr.pointee.ifa_name)

        var builder = builders[name] ?? InterfaceBuilder()
        builder.isActive = isUp && isRunning
        builder.isLoopback = isLoopback

        if family == AF_INET {
          if builder.ipAddress.isEmpty, let ip = numericHost(from: sa) {
            builder.ipAddress = ip
          }
          if builder.netmask == nil, let netmaskAddr = addr.pointee.ifa_netmask {
            builder.netmask = numericHost(from: netmaskAddr)
          }
          if builder.broadcastAddress == nil, (flags & IFF_BROADCAST) != 0,
            let dst = addr.pointee.ifa_dstaddr
          {
            builder.broadcastAddress = numericHost(from: dst)
          }
        } else if let ip = numericHost(from: sa), shouldPreferIPv6(ip, existing: builder.ipv6Address)
        {
          builder.ipv6Address = ip
        }

        builders[name] = builder
      }

      var interfaces: [NetworkInterface] = []
      var primaryIP: String? = nil
      for (name, builder) in builders {
        let ipAddress = builder.ipAddress.isEmpty ? (builder.ipv6Address ?? "") : builder.ipAddress
        guard !ipAddress.isEmpty else { continue }

        let type: NetworkInterfaceType
        if builder.isLoopback {
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

        interfaces.append(
          NetworkInterface(
            name: name,
            ipAddress: ipAddress,
            type: type,
            isActive: builder.isActive,
            ipv6Address: builder.ipv6Address,
            netmask: builder.netmask,
            broadcastAddress: builder.broadcastAddress
          )
        )

        if primaryIP == nil && builder.isActive && !builder.isLoopback && !builder.ipAddress.isEmpty
        {
          primaryIP = builder.ipAddress
        }
      }

      interfaces.sort { $0.name < $1.name }
      return (primaryIP, interfaces)
    }

    private static func shouldPreferIPv6(_ candidate: String, existing: String?) -> Bool {
      guard let existing else { return true }
      let candidateIsLinkLocal = candidate.lowercased().hasPrefix("fe80")
      let existingIsLinkLocal = existing.lowercased().hasPrefix("fe80")
      if existingIsLinkLocal && !candidateIsLinkLocal { return true }
      return false
    }

    private static func numericHost(from sa: UnsafePointer<sockaddr>) -> String? {
      var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
      let length = socklen_t(sa.pointee.sa_len)
      guard
        getnameinfo(
          sa, length,
          &hostname, socklen_t(hostname.count),
          nil, 0, NI_NUMERICHOST
        ) == 0
      else { return nil }
      return String(cString: hostname)
    }
  }

#endif
