// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Frida",
    products: [
        .library(
            name: "Frida",
            targets: ["Frida"]
        ),
    ],
    targets: [
        // TODO: Once Swift 5.9 releases and build tool plugins can request network
        // access, we should eventually create this xcframework ourselves via such.
        //
        // For now, we download libfrida-core manually.
        .binaryTarget(
            name: "libfrida-core",
            url: "https://github.com/spotlightishere/swift-frida/releases/download/16.0.19/libfrida-core.xcframework.zip",
            checksum: "782c64761cebbdbb0cb7bb1a296c9f89e04e833237d6e9dce48c6a0dfad6c653"
        ),
        .target(
            name: "Frida",
            dependencies: ["libfrida-core"],
            // Necessary for libfrida-core. We cannot provide dependencies otherwise.
            // See also: https://github.com/apple/swift-package-manager/issues/4449
            linkerSettings: [
                .linkedLibrary("resolv"),
            ]
        ),
        .testTarget(
            name: "FridaTests",
            dependencies: ["Frida"]
        ),
    ]
)
