// swift-tools-version: 6.2
import PackageDescription

let packageName = "swift-composable-architecture-extras"
let productName = "ComposableArchitectureExtras"

let tcaPackageDependencies: [Package.Dependency] = [
  .package(
    url: "https://github.com/pointfreeco/swift-composable-architecture",
    from: "1.23.1")
]

let tcaTargetDependencies: Target.Dependency =
  .product(name: "ComposableArchitecture", package: "swift-composable-architecture")

let package = Package(
  name: packageName,
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .library(
      name: productName,
      targets: ["FormValidation", "Filter"]
    )

  ],
  dependencies: tcaPackageDependencies,
  targets: [
    .target(
      name: "Analytics",
      dependencies: [
        tcaTargetDependencies
      ],
      exclude: ["README.md"]
    ),
    .testTarget(
      name: "AnalyticsTests",
      dependencies: ["Analytics"]
    ),
    .target(
      name: "Filter",
      dependencies: [
        tcaTargetDependencies
      ]
    ),
    .target(
      name: "FormValidation",
      dependencies: [
        tcaTargetDependencies
      ]
    ),
    .testTarget(
      name: "FormValidationTests",
      dependencies: ["FormValidation"]
    ),
    .testTarget(
      name: "FilterTests",
      dependencies: ["Filter"]
    ),
  ]
)
