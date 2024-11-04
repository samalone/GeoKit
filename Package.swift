// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GeoKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GeoKit",
            targets: ["GeoKit"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "4.0.0"),
//        .package(url: "https://github.com/vapor/jwt-kit.git", exact: "4.13.4")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "GeoKit",
            dependencies: [
                .product(name: "JWT", package: "jwt"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides/blob/main/docs/building.md#building-for-production> for details.
//                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release)),
//                .unsafeFlags(["-symbol-graph-minimum-access-level", "private"], .when(configuration: .debug))
            ]
        ),
        .testTarget(
            name: "GeoKitTests",
            dependencies: ["GeoKit"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
    ]
)
