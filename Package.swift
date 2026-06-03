// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWSpectrumViewUI",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "WWSpectrumViewUI", targets: ["WWSpectrumViewUI"]),
    ],
    targets: [
        .target(name: "WWSpectrumViewUI", resources: [.copy("Privacy")]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
