// swift-tools-version: 6.2
import PackageDescription

let packageName = "swift-composable-architecture-extras"
let productName = "ComposableArchitectureExtras"

let packageDependencies: [Package.Dependency] = [
  .package(
    url: "https://github.com/pointfreeco/swift-composable-architecture",
    from: "1.23.1")
]

let package = Package(
  name: packageName,
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
  ],
  products: [
    .library(
      name: productName,
      targets: ["FormValidation", "Filter"]
    )

  ],
  dependencies: packageDependencies,
  targets: [
    .target(
      name: "Filter",
      dependencies: [
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        )
      ]
    ),
    .target(
      name: "FormValidation",
      dependencies: [
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        )
      ]
    ),
    .testTarget(
      name: "FormValidationTests",
      dependencies: ["FormValidation"]
    ),
  ]
)
