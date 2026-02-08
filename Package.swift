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
  dependencies: [.tca(), .deviceKit()],
  targets: [
    .mainUmbrellaTarget(),
    .reducersUmbrellaTarget(),
    .reducerUmbrellaTestTarget(),
    .dependenciesUmbrellaTarget(),
    .dependencyUmbrellaTestTarget(),
    .reducerTarget(name: "Analytics"),
    .reducerTarget(name: "Filter"),
    .reducerTarget(name: "FormValidation"),
    .reducerTarget(name: "Haptics"),
    .reducerTarget(name: "Printers"),
    .reducerTarget(name: "ScreenAwake"),
    .reducerTarget(name: "ScreenBrightness"),
    .dependencyTarget(name: "AppInfo"),
    .dependencyTarget(
      name: "DeviceInfo",
      extraDependencies: [
        .product(
          name: "DeviceKit", package: "DeviceKit",
          condition: .when(platforms: [.iOS, .tvOS, .watchOS]))
      ]
    ),
    .dependencyTarget(name: "OpenSettings"),
    .dependencyTarget(name: "OpenURL"),
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
      ],
      path: "Sources/Reducers/ReducersExtras"
    )
  }

  static func dependenciesUmbrellaTarget() -> PackageDescription.Target {
    return .target(
      name: "DependenciesExtras",
      dependencies: [
        "AppInfo",
        "DeviceInfo",
        "OpenSettings",
        "OpenURL",
      ],
      path: "Sources/Dependencies/DependenciesExtras"
    )
  }

  static func reducerTarget(name: String) -> PackageDescription.Target {
    let tcaDep: Target.Dependency = .product(
      name: "ComposableArchitecture",
      package: "swift-composable-architecture")

    return .target(
      name: name,
      dependencies: [tcaDep],
      path: "Sources/Reducers/\(name)",
      exclude: ["README.md"]
    )
  }

  static func dependencyTarget(
    name: String,
    extraDependencies: [Target.Dependency] = []
  ) -> PackageDescription.Target {
    let tcaDep: Target.Dependency = .product(
      name: "ComposableArchitecture",
      package: "swift-composable-architecture")

    return .target(
      name: name,
      dependencies: [tcaDep] + extraDependencies,
      path: "Sources/Dependencies/\(name)",
      exclude: ["README.md"]
    )
  }

  static func reducerUmbrellaTestTarget() -> PackageDescription.Target {
    return .testTarget(
      name: "ReducersExtrasTests",
      dependencies: [.target(name: "ReducersExtras")],
      path: "Tests/Reducers/ReducersExtrasTests"
    )
  }

  static func dependencyUmbrellaTestTarget() -> PackageDescription.Target {
    return .testTarget(
      name: "DependenciesExtrasTests",
      dependencies: [.target(name: "DependenciesExtras")],
      path: "Tests/Dependencies/DependenciesExtrasTests"
    )
  }

}

extension Package.Dependency {
  static func tca() -> Package.Dependency {
    return .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      from: "1.23.1")
  }

  static func deviceKit() -> Package.Dependency {
    return .package(
      url: "https://github.com/devicekit/DeviceKit.git",
      from: "5.7.0")
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
