// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreFlow",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "CoreFlow",
            targets: ["CoreFlow"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/Swinject/Swinject.git",
            exact: "2.10.0"
        )
    ],
    targets: [
        .target(
            name: "CoreFlow",
            dependencies: [
                .product(name: "Swinject", package: "Swinject")
            ]
        ),
    ]
)
