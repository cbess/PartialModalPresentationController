// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "PartialModalPresentationController",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "PartialModalPresentationController",
            targets: ["PartialModalPresentationController"]
        )
    ],
    targets: [
        .target(
            name: "PartialModalPresentationController",
            dependencies: [],
            path: "Sources"
        ),
    ],
    swiftLanguageVersions: [
        .version("5.2")
    ]
)
