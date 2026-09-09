#if !os(watchOS)

  import Darwin
  import Foundation

  enum ExternalIPMeasurement {
    private static let endpoint = URL(string: "https://icanhazip.com/")!

    static func measure() async -> String? {
      var request = URLRequest(url: endpoint)
      request.timeoutInterval = 5
      request.cachePolicy = .reloadIgnoringLocalCacheData
      do {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode)
        else {
          return nil
        }
        let value =
          String(data: data, encoding: .utf8)?
          .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return isPlausibleIPAddress(value) ? value : nil
      } catch {
        return nil
      }
    }

    private static func isPlausibleIPAddress(_ value: String) -> Bool {
      guard !value.isEmpty, value.count <= 45 else { return false }
      var ipv4 = in_addr()
      var ipv6 = in6_addr()
      return value.withCString { pointer in
        inet_pton(AF_INET, pointer, &ipv4) == 1 || inet_pton(AF_INET6, pointer, &ipv6) == 1
      }
    }
  }

#endif
