public struct LocalizationInfo: Sendable, Equatable {
  public let localeIdentifier: String
  public let languageCode: String
  public let regionCode: String?
  public let timeZoneIdentifier: String
  public let currencySymbol: String
  public let currencyCode: String?

  public init(
    localeIdentifier: String,
    languageCode: String,
    regionCode: String?,
    timeZoneIdentifier: String,
    currencySymbol: String,
    currencyCode: String?
  ) {
    self.localeIdentifier = localeIdentifier
    self.languageCode = languageCode
    self.regionCode = regionCode
    self.timeZoneIdentifier = timeZoneIdentifier
    self.currencySymbol = currencySymbol
    self.currencyCode = currencyCode
  }

  public static let empty = LocalizationInfo(
    localeIdentifier: "",
    languageCode: "",
    regionCode: nil,
    timeZoneIdentifier: "",
    currencySymbol: "",
    currencyCode: nil
  )
}
