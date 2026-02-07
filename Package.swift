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
    .singleUmbrellaLibrary(name: "ComposableArchitectureExtras")
  ],
  dependencies: [.tca()],
  targets: [
    .mainUmbrellaTarget(),
    .reducersUmbrellaTarget(),
    .umbrellaTestTarget(for: "ReducersExtras"),
    .dependenciesUmbrellaTarget(),
    .umbrellaTestTarget(for: "DependenciesExtras"),
    .tcaTarget(name: "Analytics"),
    .tcaTarget(name: "AppInfo"),
    .tcaTarget(name: "Filter"),
    .tcaTarget(name: "FormValidation"),
    .tcaTarget(name: "Haptics"),
    .tcaTarget(name: "Printers"),
    .tcaTarget(name: "ScreenAwake"),
    .tcaTarget(name: "ScreenBrightness"),
  ]
)

extension PackageDescription.Target {

  static func mainUmbrellaTarget() -> PackageDescription.Target {
    return .target(
      name: "ComposableArchitectureExtras",
      dependencies: [
        "ReducersExtras",
        "DependenciesExtras",
      ]
    )
  }

  static func reducersUmbrellaTarget() -> PackageDescription.Target {
    return .target(
      name: "ReducersExtras",
      dependencies: [
        "Analytics",
        "Filter",
        "FormValidation",
        "Haptics",
        "Printers",
        "ScreenAwake",
        "ScreenBrightness",
      ]
    )
  }

  static func dependenciesUmbrellaTarget() -> PackageDescription.Target {
    return .target(
      name: "DependenciesExtras",
      dependencies: [
        "AppInfo"
      ]
    )
  }

  static func tcaTarget(name: String) -> PackageDescription.Target {
    let tcaTargetDependencies: Target.Dependency = .product(
      name: "ComposableArchitecture",
      package: "swift-composable-architecture")
    let excludeReadme: [String] = ["README.md"]

    return .target(
      name: name,
      dependencies: [tcaTargetDependencies],
      exclude: excludeReadme
    )
  }

  static func umbrellaTestTarget(for target: String) -> PackageDescription.Target {
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
  static func singleUmbrellaLibrary(name: String) -> PackageDescription.Product {
    return .library(
      name: name,
      targets: [name]
    )
  }
}
