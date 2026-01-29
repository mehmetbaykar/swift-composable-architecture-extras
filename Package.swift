// swift-tools-version: 6.2
import PackageDescription

let package = Package(
  name: "swift-composable-architecture-extras",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .singleLibraryForAllTargets(name: "ComposableArchitectureExtras")
  ],
  dependencies: [.tca()],
  targets: [
    .tcaTarget(name: "Analytics"),
    .tcaTestTarget(for: "Analytics"),
    .tcaTarget(name: "Filter"),
    .tcaTestTarget(for: "Filter"),
    .tcaTarget(name: "FormValidation"),
    .tcaTestTarget(for: "FormValidation"),
  ]
)

extension PackageDescription.Target {
  static func tcaTarget(name: String) -> PackageDescription.Target {
    let tcaTargetDependencies: Target.Dependency =
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
    let excludeReadme: [String] = ["README.md"]

    return .target(
      name: name,
      dependencies: [tcaTargetDependencies],
      exclude: excludeReadme
    )
  }

  static func tcaTestTarget(for target: String) -> PackageDescription.Target {
    return .testTarget(
      name: "\(target)Tests",
      dependencies: [.target(name: target)]
    )
  }
}

extension Package.Dependency {
  static func tca() -> Package.Dependency {
    return .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      from: "1.23.1")
  }
}

extension PackageDescription.Product {
  static func singleLibraryForAllTargets(name: String) -> PackageDescription.Product {
    return .library(name: name, targets: ["Analytics", "Filter", "FormValidation"])
  }
}
