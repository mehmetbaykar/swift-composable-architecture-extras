import Foundation

enum LocalizationMeasurement {
  static func measure() -> LocalizationInfo {
    let locale = Locale.current
    let languageCode =
      Locale.preferredLanguages.first ?? locale.language.languageCode?.identifier ?? ""
    return LocalizationInfo(
      localeIdentifier: locale.identifier,
      languageCode: languageCode,
      regionCode: locale.region?.identifier,
      timeZoneIdentifier: TimeZone.current.identifier,
      currencySymbol: locale.currencySymbol ?? "",
      currencyCode: locale.currency?.identifier
    )
  }
}
