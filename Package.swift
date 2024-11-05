// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "GeoKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "GeoKit",
            targets: ["GeoKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "GeoKit",
            dependencies: [
                .product(name: "JWT", package: "jwt"),
            ]
        ),
        .testTarget(
            name: "GeoKitTests",
            dependencies: ["GeoKit"]
        ),
    ]
)
