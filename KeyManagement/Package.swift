// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "KeyManagement",
    products: [
        .library(
            name: "KeyStore",
            targets: ["KeyManagement"]),
        .library(
            name: "KeyChain",
            targets: ["KeyManagement"])
    ],
    dependencies: [
        .package(url: "https://github.com/GigaBitcoin/secp256k1.swift", branch: "main")
    ],
    targets: [
        .target(
            name: "KeyManagement",
            dependencies: []),
        .testTarget(
            name: "KeyManagementTests",
            dependencies: ["KeyManagement"]),
    ]
)
