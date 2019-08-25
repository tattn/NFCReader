// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NFCReader",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(
            name: "NFCReader",
            targets: ["NFCReader"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "NFCReader",
            dependencies: []),
        .testTarget(
            name: "NFCReaderTests",
            dependencies: ["NFCReader"]),
    ]
)
