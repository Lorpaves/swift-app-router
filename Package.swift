// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-app-router",
    platforms: [.iOS(.v13), .watchOS(.v6), .tvOS(.v13), .visionOS(.v1), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Router",
            targets: ["AppRouter"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swhitty/swift-mutex.git", .upToNextMajor(from: "0.0.5"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AppRouter",
            dependencies: [
                .product(name: "Mutex", package: "swift-mutex")
            ]
        ),
        .testTarget(
            name: "AppRouterTests",
            dependencies: ["AppRouter"]
        ),
    ]
)
