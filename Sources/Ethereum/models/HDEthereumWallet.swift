import Foundation
import MnemonicSwift
import CryptoSwift

import typealias Model.ByteArray
import class Model.EthereumPrivateKey
import struct Model.EthereumPublicKey
import struct Model.EthereumAddress

public final class HDEthereumWallet {

    private let privateKey: HDEthereumPrivateKey
    private let seed: ByteArray

    public enum Error: Swift.Error {
        case retrieveSeedBytes
    }

    enum Constants {
        static let bitcoinSeed: ByteArray = [66, 105, 116, 99, 111, 105, 110, 32, 115, 101, 101, 100]
    }

    /// Creates a new EthereumSeedPhrase generating a new seed phrase
    /// - Parameter seed: The seed in bytes format
    public convenience init() throws {
        let mnemonic: String = try Mnemonic.generateMnemonic(strength: 128)
        let deterministicSeed: ByteArray = try Mnemonic.deterministicSeedBytes(from: mnemonic)
        try self.init(seed: deterministicSeed)
    }

    /// Creates a new EthereumSeedPhrase with the given mnemonic string
    /// - Parameter seed: The seed in bytes format
    public convenience init(mnemonic: String) throws {
        let deterministicSeed: ByteArray = try Mnemonic.deterministicSeedBytes(from: mnemonic)
        try self.init(seed: deterministicSeed)
    }

    /// Creates a new EthereumSeedPhrase with the given seed
    /// - Parameter seed: The seed in bytes format
    public init(seed: ByteArray) throws {
        let hmac = HMAC(key: Constants.bitcoinSeed, variant: .sha2(.sha512))
        let computedHMAC = try hmac.authenticate(seed)
        self.seed = seed
        self.privateKey = HDEthereumPrivateKey(
            key: EthereumPrivateKey(rawBytes: ByteArray(computedHMAC[0..<32])),
            chainCode: ByteArray(computedHMAC[32..<64]),
            depth: 0,
            parentFingerprint: 0,
            childNumber: 0
        )
    }

    public func getAddress(at index: UInt32) throws -> EthereumAddress {
        let privateKey = try generateExternalPrivateKey(at: index)
        let account = EthereumWallet(privateKey: privateKey)
        return try account.address
    }

    public func getPublicKey(at index: UInt32) throws -> EthereumPublicKey {
        let privateKey = try generateExternalPrivateKey(at: index)
        let account = EthereumWallet(privateKey: privateKey)
        return try account.publicKey
    }

    public func generateExternalPrivateKey(at index: UInt32) throws -> EthereumPrivateKey {
        let nodePrivateKey = try ethereumPrivateKey(index)
        return EthereumPrivateKey(rawBytes: nodePrivateKey.data.bytes)
    }

    private func ethereumPrivateKey(_ index: UInt32) throws -> HDEthereumPrivateKey {
        return try privateKey
            .derivePath()
            .deriveChild(index)
    }
}
