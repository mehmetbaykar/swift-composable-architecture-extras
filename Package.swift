// swift-tools-version: 6.3
import PackageDescription

let package = Package(
  name: "swift-composable-architecture-extras",
  platforms: [
    .iOS(.v16),
    .macOS(.v15),
    .tvOS(.v16),
    .watchOS(.v9),
  ],
  products: [
    // Umbrellas
    .singleTargetLibrary(name: "ComposableArchitectureExtras"),
    .singleTargetLibrary(name: "DependenciesExtras"),
    .singleTargetLibrary(name: "ReducersExtras"),
    // Standalone — Dependencies
    .singleTargetLibrary(name: "AppInfo"),
    .singleTargetLibrary(name: "AudioPlayer"),
    .singleTargetLibrary(name: "DeviceInfo"),
    .singleTargetLibrary(name: "LoggerClient"),
    .singleTargetLibrary(name: "OpenSettings"),
    .singleTargetLibrary(name: "OpenURL"),
    .singleTargetLibrary(name: "ShellClient"),
    .singleTargetLibrary(name: "LaunchAtLogin"),
    // Standalone — Reducers
    .singleTargetLibrary(name: "Analytics"),
    .singleTargetLibrary(name: "AppStoreOverlay"),
    .singleTargetLibrary(name: "Filter"),
    .singleTargetLibrary(name: "FormValidation"),
    .singleTargetLibrary(name: "Haptics"),
    .singleTargetLibrary(name: "Printers"),
    .singleTargetLibrary(name: "ScreenAwake"),
    .singleTargetLibrary(name: "ScreenBrightness"),
  ],
  traits: [
    .default(enabledTraits: ["Dependencies", "Reducers"]),
    .trait(
      name: "Dependencies",
      description: "Enable dependency-only modules"
    ),
    .trait(
      name: "Reducers",
      description: "Enable reducer modules"
    ),
  ],
  dependencies: {
    var deps: [Package.Dependency] = [.tca(), .deviceKit()]
    #if os(macOS)
      deps.append(.subprocess())
    #endif
    return deps
  }(),
  targets: [
    .mainUmbrellaTarget(),
    .mainUmbrellaTestTarget(),
    .reducersUmbrellaTarget(),
    .reducerUmbrellaTestTarget(),
    .dependenciesUmbrellaTarget(),
    .dependencyUmbrellaTestTarget(),
    .reducerTarget(name: "AppStoreOverlay"),
    .reducerTarget(name: "Analytics"),
    .reducerTarget(name: "Filter"),
    .reducerTarget(name: "FormValidation"),
    .reducerTarget(name: "Haptics"),
    .reducerTarget(name: "Printers"),
    .reducerTarget(name: "ScreenAwake"),
    .reducerTarget(name: "ScreenBrightness"),
    .dependencyTarget(name: "AppInfo"),
    .dependencyTarget(name: "AudioPlayer"),
    .dependencyTarget(name: "LoggerClient"),
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
    .target(
      name: "ShellClient",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(
          name: "Subprocess",
          package: "swift-subprocess",
          condition: .when(platforms: [.macOS])),
      ],
      path: "Sources/Dependencies/ShellClient",
      exclude: ["README.md"]
    ),
    .dependencyTarget(name: "LaunchAtLogin"),
  ]
)

extension PackageDescription.Target {

  static func mainUmbrellaTarget() -> PackageDescription.Target {
    return .target(
      name: "ComposableArchitectureExtras",
      dependencies: [
        .target(
          name: "ReducersExtras",
          condition: .when(traits: ["Reducers"])
        ),
        .target(
          name: "DependenciesExtras",
          condition: .when(traits: ["Dependencies"])
        ),
      ],
      resources: [.process("Resources")]
    )
  }

  static func reducersUmbrellaTarget() -> PackageDescription.Target {
    return .target(
      name: "ReducersExtras",
      dependencies: [
        "AppStoreOverlay",
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
        "AudioPlayer",
        "DeviceInfo",
        "LoggerClient",
        "OpenSettings",
        "OpenURL",
        "ShellClient",
        "LaunchAtLogin",
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

  static func mainUmbrellaTestTarget() -> PackageDescription.Target {
    return .testTarget(
      name: "ComposableArchitectureExtrasTests",
      dependencies: [.target(name: "ComposableArchitectureExtras")],
      path: "Tests/ComposableArchitectureExtrasTests"
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
      from: "1.26.0")
  }

  static func deviceKit() -> Package.Dependency {
    return .package(
      url: "https://github.com/devicekit/DeviceKit.git",
      from: "5.8.0")
  }

  static func subprocess() -> Package.Dependency {
    return .package(
      url: "https://github.com/swiftlang/swift-subprocess.git",
      "0.4.0"..<"0.5.0")
  }
}

extension PackageDescription.Product {
  static func singleTargetLibrary(name: String) -> PackageDescription.Product {
    return .library(
      name: name,
      targets: [name]
    )
  }
}
