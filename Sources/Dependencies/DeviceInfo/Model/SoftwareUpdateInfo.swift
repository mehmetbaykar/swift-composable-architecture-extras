#if os(macOS)

  import Foundation

  /// A pending macOS software update read from the system's `com.apple.SoftwareUpdate` domain.
  public struct SoftwareUpdateInfo: Sendable, Equatable, Identifiable {
    /// Unique product key for this update (e.g., "MSU_UPDATE_24E248_patch_15.4_rsr").
    public let id: String

    /// Human-readable update name (e.g., "macOS Sequoia 15.4").
    public let displayName: String

    /// Version string of the update (e.g., "15.4").
    public let displayVersion: String

    /// Whether this update targets a different major macOS version than the current one.
    public let isMajorUpdate: Bool

    /// The raw product key used by the Software Update system.
    public let productKey: String

    public init(
      id: String,
      displayName: String,
      displayVersion: String,
      isMajorUpdate: Bool,
      productKey: String
    ) {
      self.id = id
      self.displayName = displayName
      self.displayVersion = displayVersion
      self.isMajorUpdate = isMajorUpdate
      self.productKey = productKey
    }
  }

#endif
