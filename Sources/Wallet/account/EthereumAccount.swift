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

        return try keyDecrypt.decrypt(address.eip55Description, cipherText: ciphertext, handler: { key in
            content(key)
        })
    }

    public func signDigest(_ digest: ByteArray) throws -> Signature {
        // 1. Get the ciphertext stored in the keychain
        guard let ciphertext = try keyStorage.get(key: address.eip55Description) else {
            throw Error.notImported
        }

        // 2. Decrypt ciphertext, return the signature
        return try keyDecrypt.decrypt(address.eip55Description, cipherText: ciphertext, handler: { key in
            try sign(digest, privateKey: key)
        })
    }
}
