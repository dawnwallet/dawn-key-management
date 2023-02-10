// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "KeyManagement",
    products: [
        .library(
            name: "Keystore",
            targets: ["Keystore"]),
        .library(
            name: "Keychain",
            targets: ["Keychain"])
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift", from: "1.5.1"),
        .package(url: "https://github.com/GigaBitcoin/secp256k1.swift", branch: "main")
    ],
    targets: [
        .target(
            name: "Keychain",
            dependencies: [
                "CryptoSwift",
                .product(name: "secp256k1", package: "secp256k1.swift")
            ]),
        .testTarget(
            name: "KeychainTests",
            dependencies: ["Keychain"]),
        .target(
            name: "Keystore",
            dependencies: [
                .product(name: "secp256k1", package: "secp256k1.swift")
            ]),
        .testTarget(
            name: "KeystoreTests",
            dependencies: ["Keystore"]),
    ]
)
