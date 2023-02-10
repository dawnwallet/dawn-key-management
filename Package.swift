// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "KeyManagement",
    products: [
        .library(
            name: "Account",
            targets: ["Account"]),
        .library(
            name: "Keychain",
            targets: ["Keychain"]),
        .library(
            name: "Signing",
            targets: ["Signing"])
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift", from: "1.5.1"),
        .package(url: "https://github.com/GigaBitcoin/secp256k1.swift", branch: "main")
    ],
    targets: [
        .target(name: "Keychain", dependencies: ["Model"]),
        .testTarget(name: "KeychainTests", dependencies: ["Keychain"]),
        .target(name: "Account", dependencies: ["Model"]),
        .testTarget(name: "AccountTests", dependencies: ["Account"]),
        .target(name: "Model", dependencies: ["CryptoSwift"]),
        .testTarget(name: "ModelTests", dependencies: ["Model"]),
        .target(name: "Signing", dependencies: [.product(name: "secp256k1", package: "secp256k1.swift"), "Model"]),
        .testTarget(name: "SigningTests", dependencies: ["Signing"]),
    ]
)
