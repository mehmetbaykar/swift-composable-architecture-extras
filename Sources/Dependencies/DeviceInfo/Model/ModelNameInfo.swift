#if os(macOS)

  /// The marketing name and metadata for a Mac model.
  ///
  /// Resolved locally via `ioreg` on Apple Silicon, or via Apple's
  /// `support-sp.apple.com` API on Intel Macs.
  public struct ModelNameInfo: Sendable, Equatable {
    /// Raw model identifier from the system (e.g., "Mac16,1" or "MacBookPro18,3").
    public let modelIdentifier: String

    /// Full marketing name (e.g., "MacBook Pro" on Apple Silicon,
    /// "MacBook Pro (Late 2021)" on Intel).
    public let marketingName: String

    /// Short product line name (e.g., "MacBook Pro", "Mac mini", "iMac").
    public let shortName: String

    /// Model year extracted from Apple's API response. Only available on Intel Macs.
    public let year: String?

    /// SF Symbol name representing this Mac model (e.g., "laptopcomputer", "macmini.fill").
    public let iconSymbolName: String

    public init(
      modelIdentifier: String,
      marketingName: String,
      shortName: String,
      year: String?,
      iconSymbolName: String
    ) {
      self.modelIdentifier = modelIdentifier
      self.marketingName = marketingName
      self.shortName = shortName
      self.year = year
      self.iconSymbolName = iconSymbolName
    }

    /// A placeholder value used when model information cannot be determined.
    public static let unknown = ModelNameInfo(
      modelIdentifier: "",
      marketingName: "",
      shortName: "",
      year: nil,
      iconSymbolName: "desktopcomputer"
    )
  }

#endif
