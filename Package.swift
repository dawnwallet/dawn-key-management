// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "KeyManagement",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "Account",
            targets: ["Account"]),
        .library(
            name: "Ethereum",
            targets: ["Ethereum"])
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift", from: "1.5.1"),
        .package(url: "https://github.com/GigaBitcoin/secp256k1.swift", branch: "main"),
        .package(url: "https://github.com/zcash-hackworks/MnemonicSwift", from: "2.2.4")
    ],
    targets: [
        .target(name: "Account", dependencies: ["Model"]),
        .testTarget(name: "AccountTests", dependencies: ["Account"]),
        .target(name: "Ethereum", dependencies: [
            .product(name: "secp256k1", package: "secp256k1.swift"),
            "Model",
            "MnemonicSwift"
        ]),
        .testTarget(name: "EthereumTests", dependencies: ["Ethereum"]),
        .target(name: "Keychain", dependencies: ["Model"]),
        .testTarget(name: "KeychainTests", dependencies: ["Keychain"]),
        .target(name: "Model", dependencies: ["CryptoSwift"]),
        .testTarget(name: "ModelTests", dependencies: ["Model"])
    ]
)
