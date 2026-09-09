#if os(iOS)

  import CoreTelephony
  import Foundation

  enum CarrierMeasurement {
    static func measure() -> CarrierInfo {
      let networkInfo = CTTelephonyNetworkInfo()
      let radio =
        networkInfo.serviceCurrentRadioAccessTechnology?.values.first
        .map { $0.replacingOccurrences(of: "CTRadioAccessTechnology", with: "") }

      let providers = networkInfo.serviceSubscriberCellularProviders
      let carrier = providers?.values.first { sanitized($0.carrierName) != nil }
        ?? providers?.values.first

      return CarrierInfo(
        name: sanitized(carrier?.carrierName),
        mobileCountryCode: sanitized(carrier?.mobileCountryCode),
        mobileNetworkCode: sanitized(carrier?.mobileNetworkCode),
        isoCountryCode: sanitized(carrier?.isoCountryCode),
        allowsVOIP: carrier?.allowsVOIP ?? false,
        radioAccessTechnology: sanitized(radio)
      )
    }

    private static func sanitized(_ value: String?) -> String? {
      guard let value, !value.isEmpty else { return nil }
      let placeholders: Set<String> = ["--", "65535", "00000"]
      if placeholders.contains(value) { return nil }
      return value
    }
  }

#endif
