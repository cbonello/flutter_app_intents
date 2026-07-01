// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_app_intents",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        // Plugin name contains "_", so the library name uses "-" instead.
        .library(name: "flutter-app-intents", targets: ["flutter_app_intents"])
    ],
    dependencies: [
        .package(path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "flutter_app_intents",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
