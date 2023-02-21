import Foundation
import Model
import Keychain

public final class EthereumAccount {

    enum Error: Swift.Error {
        case notImported
        case wrongAddress
        case memoryBound
        case createContext
        case parseECDSA
        case invalidKey
    }

    private let address: EthereumAddress
    private let keyDecrypt: KeyDecryptable
    private let keyStorage: KeyStoring

    public convenience init(address: EthereumAddress) {
        self.init(address: address, keyDecrypt: KeyDecrypting(), keyStorage: KeyStorage())
    }

    private init(address: EthereumAddress, keyDecrypt: KeyDecryptable, keyStorage: KeyStoring) {
        self.address = address
        self.keyDecrypt = keyDecrypt
        self.keyStorage = keyStorage
    }
}

extension EthereumAccount {
    public func accessPrivateKey<T>(_ content: (ByteArray) -> T) throws -> T {
        // 1. Get the ciphertext stored in the keychain
        guard let ciphertext = try keyStorage.get(key: address.eip55Description) else {
            throw Error.notImported
        }

        let decryptedKey = try keyDecrypt.decrypt(address.eip55Description, cipherText: ciphertext)

        let privateKey = decryptedKey.withDecryptedBytes { key in
            content(key)
        }

        return privateKey
    }

    public func signDigest(_ digest: ByteArray) throws -> Signature {
        // 1. Get the ciphertext stored in the keychain
        guard let ciphertext = try keyStorage.get(key: address.eip55Description) else {
            throw Error.notImported
        }

        // 2.
        let decryptedKey = try keyDecrypt.decrypt(address.eip55Description, cipherText: ciphertext)

        // 2. Decrypt the ciphertext
        let signature: Signature = try decryptedKey.withDecryptedBytes { key in
            return try sign(digest, privateKey: key)
        }
        return signature
    }
}
