// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QSlider",
    platforms: [
        .iOS(.v15),       // SwiftUI from iOS 15
        .macOS(.v12)   // macOS from 12
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "QSlider",
            targets: ["QSlider"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "QSlider"),
        .testTarget(
            name: "QSliderTests",
            dependencies: ["QSlider"]
        ),
    ]
)
