#if os(iOS)

  public struct CarrierInfo: Sendable, Equatable {
    public let name: String?
    public let mobileCountryCode: String?
    public let mobileNetworkCode: String?
    public let isoCountryCode: String?
    public let allowsVOIP: Bool
    public let radioAccessTechnology: String?

    public init(
      name: String?,
      mobileCountryCode: String?,
      mobileNetworkCode: String?,
      isoCountryCode: String?,
      allowsVOIP: Bool,
      radioAccessTechnology: String?
    ) {
      self.name = name
      self.mobileCountryCode = mobileCountryCode
      self.mobileNetworkCode = mobileNetworkCode
      self.isoCountryCode = isoCountryCode
      self.allowsVOIP = allowsVOIP
      self.radioAccessTechnology = radioAccessTechnology
    }

    public static let unknown = CarrierInfo(
      name: nil,
      mobileCountryCode: nil,
      mobileNetworkCode: nil,
      isoCountryCode: nil,
      allowsVOIP: false,
      radioAccessTechnology: nil
    )
  }

#endif
