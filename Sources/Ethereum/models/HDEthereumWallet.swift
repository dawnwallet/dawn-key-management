import Foundation
import MnemonicSwift
import CryptoSwift

import typealias Model.ByteArray
import class Model.EthereumPrivateKey
import struct Model.EthereumPublicKey
import struct Model.EthereumAddress
import protocol Keychain.KeyDecrypting
import protocol Keychain.KeyEncrypting
import class Keychain.KeyEncryptor
import class Keychain.KeyStorage
import class Keychain.KeyDecryptor

public final class HDEthereumWallet {

    private let privateKey: HDEthereumPrivateKey
    private let mnemonic: ByteArray

    public enum Error: Swift.Error {
        case retrieveSeedBytes
    }

    enum Constants {
        static let bitcoinSeed: ByteArray = [66, 105, 116, 99, 111, 105, 110, 32, 115, 101, 101, 100]
    }

    /// Creates a new HDEthereumWallet generating a new seed phrase
    /// - Parameter seed: The seed in bytes format
    public convenience init(lenght: Length = .word12) throws {
        let mnemonic: String = try Mnemonic.generateMnemonic(strength: lenght.strength)
        try self.init(mnemonic: mnemonic.bytes)
    }

    /// Creates a new HDEthereumWallet with the given mnemonic string
    /// - Parameter seed: The seed in bytes format
    public convenience init(mnemonicString: String) throws {
        try self.init(mnemonic: mnemonicString.bytes)
    }

    /// Creates a new HDEthereumWallet with the given id
    /// - Parameter seed: The seed in bytes format
    public convenience init(id: String) throws {
        let mnemonic: ByteArray = try HDEthereumWallet.decryptSeedPhrase(id)
        try self.init(mnemonic: mnemonic)
    }

    /// Creates a new HDEthereumWallet with the given seed
    /// - Parameter seed: The seed in bytes format
    public init(
        mnemonic: ByteArray,
        encrypt: KeyEncryptor = KeyEncryptor(),
        decrypt: KeyDecrypting = KeyDecryptor(),
        storage: KeyStorage = KeyStorage()
    ) throws {
        let mnemonicString = String(decoding: mnemonic, as: UTF8.self)
        let deterministicSeed: ByteArray = try Mnemonic.deterministicSeedBytes(from: mnemonicString)
        let hmac = HMAC(key: Constants.bitcoinSeed, variant: .sha2(.sha512))
        let computedHMAC = try hmac.authenticate(deterministicSeed)
        self.mnemonic = mnemonic
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

extension HDEthereumWallet {
    public func revealSeedPhrase() throws -> ByteArray {
        return mnemonic
    }
}

// Encryption / Decryption
extension HDEthereumWallet {
    @discardableResult
    static public func decryptSeedPhrase(
        _ id: String,
        storage: KeyStorage = KeyStorage(),
        decrypt: KeyDecrypting = KeyDecryptor()
    ) throws -> ByteArray {
        // 1. Get the ciphertext stored in the keychain
        guard let ciphertext = try storage.get(key: id) else {
            throw Error.retrieveSeedBytes
        }

        // 2. Decrypt the seedPhrase
        let seed = try decrypt.decryptSeed(id, cipherText: ciphertext)

        return seed
    }

    @discardableResult
    public func encryptSeedPhrase(
        storage: KeyStorage = KeyStorage(),
        encrypt: KeyEncrypting = KeyEncryptor()
    ) throws -> (mnemonic: ByteArray, id: String) {
        let seedPhraseId = UUID().uuidString
        let seedData = Data(mnemonic.bytes)

        // 1. Encrypt the seedPhrase using the generated UUID as reference
        let ciphertext = try encrypt.encrypt(seedData, with: seedPhraseId)

        // 2. Store the ciphertext in the keychain
        try storage.set(data: ciphertext as Data, key: seedPhraseId)

        return (mnemonic: mnemonic.bytes, id: seedPhraseId)
    }
}
