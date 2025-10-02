// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
// Version: 0.7.0

import PackageDescription

let package = Package(
    name: "FlutterAppIntents",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FlutterAppIntents",
            targets: ["FlutterAppIntents"]
        ),
    ],
    dependencies: [
        // Note: This package requires Flutter framework to be available in your project
        // Add Flutter through your standard Flutter iOS integration
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FlutterAppIntents",
            path: "ios/Classes",
            exclude: [
                // Exclude any files that shouldn't be part of the SPM build
                ".DS_Store"
            ]
        ),
        .testTarget(
            name: "FlutterAppIntentsTests",
            dependencies: ["FlutterAppIntents"],
            path: "ios/Tests"
        ),
    ]
)