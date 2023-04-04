import Foundation
import MnemonicSwift
import CryptoSwift
import Model
import Keychain

public final class HDEthereumWallet {

    private let privateKey: HDEthereumPrivateKey
    private let mnemonic: ByteArray

    public enum Error: Swift.Error {
        case retrieveSeedBytes
        case hdKeychainStore
    }

    enum Constants {
        static let bitcoinSeed: ByteArray = [66, 105, 116, 99, 111, 105, 110, 32, 115, 101, 101, 100]
    }

    /// Creates a new HDEthereumWallet generating a new seed phrase
    /// - Parameter seed: The seed in bytes format
    public convenience init(length: Length = .word12) throws {
        let mnemonic: String = try Mnemonic.generateMnemonic(
            strength: length.strength
        )
        try self.init(mnemonic: mnemonic.bytes)
    }

    /// Creates a new HDEthereumWallet with the given mnemonic string
    /// - Parameter seed: The seed in bytes format
    public convenience init(mnemonicString: String) throws {
        try self.init(mnemonic: mnemonicString.bytes)
    }

    private init(mnemonic: ByteArray) throws {
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

    public func generateExternalPrivateKey(at index: UInt32) throws -> EthereumPrivateKey {
        try ethereumPrivateKey(index)
            .privateKey()
    }

    private func ethereumPrivateKey(_ index: UInt32) throws -> HDEthereumPrivateKey {
        return try privateKey
            .derivePath()
            .deriveChild(index)
    }
}

 extension HDEthereumWallet {

    /// Generate an external private key given the id generated during encryption
    public static func generateExternalPrivateKey(
        with seedId: String,
        at index: UInt32
    ) throws -> EthereumPrivateKey {
        try HDEthereumWallet.accessSeedPhrase(id: seedId) { key in
            try HDEthereumWallet(mnemonicString: String(decoding: key, as: UTF8.self))
                .generateExternalPrivateKey(at: index)
        }
    }

    /// Returns the closue containing the seed
    public static func accessSeedPhrase<R>(
        id: String,
        storage: KeyStoring = KeyStorage(),
        decrypt: KeyDecryptable = KeyDecrypting(),
        _ content: (ByteArray) throws -> R
    ) throws -> R {
        // 1. Get the ciphertext stored in the keychain
        guard let ciphertext = try storage.get(key: id) else {
            throw Error.retrieveSeedBytes
        }

        // 2. Decrypt the seedPhrase, return the closure containing it
        return try decrypt.decrypt(id, cipherText: ciphertext, handler: { key in
            try content(key)
        })
    }
}

extension HDEthereumWallet {

    @discardableResult
    public func encryptSeedPhrase(
        storage: KeyStoring = KeyStorage(),
        encrypt: KeyEncryptable = KeyEncrypting()
    ) throws -> String {
        let seedId = UUID().uuidString
        let seedData = Data(mnemonic.bytes)

        // 1. Encrypt the seedPhrase using the generated UUID as reference
        let ciphertext = try encrypt.encrypt(seedData, with: seedId)

        // 2. Store the ciphertext in the keychain
        guard storage.set(data: ciphertext as Data, key: seedId) == errSecSuccess else {
            throw Error.hdKeychainStore
        }

        return seedId
    }
}
