import Foundation
import MnemonicSwift
import CryptoSwift
import Model
import Keychain

public final class HDEthereumWallet {

    private let privateKey: HDEthereumPrivateKey
    private let seedPhraseId: String
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
        let mnemonic: String = try Mnemonic.generateMnemonic(
            strength: lenght.strength
        )
        try self.init(mnemonic: mnemonic.bytes, id: UUID().uuidString)
    }

    /// Creates a new HDEthereumWallet with the given mnemonic string
    /// - Parameter seed: The seed in bytes format
    public convenience init(mnemonicString: String) throws {
        try self.init(mnemonic: mnemonicString.bytes, id: UUID().uuidString)
    }

    /// Creates a new HDEthereumWallet with the given Id
    /// - Parameter seed: The seed in bytes format
    public convenience init(id: String) throws {
        let mnemonic: ByteArray = try HDEthereumWallet.decryptSeedPhrase(id)
        try self.init(mnemonic: mnemonic, id: id)
    }

    /// Creates a new HDEthereumWallet with the given seed
    /// - Parameter seed: The seed in bytes format
    private init(mnemonic: ByteArray, id: String) throws {
        let mnemonicString = String(decoding: mnemonic, as: UTF8.self)
        let deterministicSeed: ByteArray = try Mnemonic.deterministicSeedBytes(from: mnemonicString)
        let hmac = HMAC(key: Constants.bitcoinSeed, variant: .sha2(.sha512))
        let computedHMAC = try hmac.authenticate(deterministicSeed)
        self.mnemonic = mnemonic
        self.seedPhraseId = id
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
    public func revealSeedPhrase() throws -> ByteArray {
        mnemonic
    }
}

extension HDEthereumWallet {
    @discardableResult
    static public func decryptSeedPhrase(
        _ id: String,
        storage: KeyStoring = KeyStorage(),
        decrypt: KeyDecryptable = KeyDecrypting()
    ) throws -> ByteArray {
        // 1. Get the ciphertext stored in the keychain
        guard let ciphertext = try storage.get(key: id) else {
            throw Error.retrieveSeedBytes
        }

        // 2. Decrypt the seedPhrase
        let decrypted =  try decrypt.decrypt(id, cipherText: ciphertext)

        return decrypted.withDecryptedBytes { key in
            key
        }
    }

    @discardableResult
    public func encryptSeedPhrase(
        storage: KeyStoring = KeyStorage(),
        encrypt: KeyEncryptable = KeyEncrypting()
    ) throws -> (mnemonic: ByteArray, id: String) {
        let seedData = Data(mnemonic.bytes)

        // 1. Encrypt the seedPhrase using the generated UUID as reference
        let ciphertext = try encrypt.encrypt(seedData, with: seedPhraseId)

        // 2. Store the ciphertext in the keychain
        try storage.set(data: ciphertext as Data, key: seedPhraseId)

        return (mnemonic: mnemonic.bytes, id: seedPhraseId)
    }
}
