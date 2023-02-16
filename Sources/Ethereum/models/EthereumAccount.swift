import Foundation
import Model

import protocol Keychain.KeyDecrypting

import class Keychain.KeyEncryptor
import class Keychain.KeyDecryptor
import class Keychain.KeyStorage

public final class EthereumAccount {

    enum Error: Swift.Error {
        case wrongAddress
        case memoryBound
        case createContext
        case parseECDSA
    }

    private let address: EthereumAddress
    private let decrypt: KeyDecrypting
    private let storage: KeyStorage

    public convenience init(address: EthereumAddress) {
        self.init(address: address, storage: KeyStorage(), decrypt: KeyDecryptor())
    }

    private init(address: EthereumAddress, storage: KeyStorage, decrypt: KeyDecrypting) {
        self.address = address
        self.storage = storage
        self.decrypt = decrypt
    }
}

// Encryption / Decryption
extension EthereumAccount {

    func decryptWallet() throws -> EthereumWallet {
        // 1. Get the ciphertext stored in the keychain
        guard let ciphertext = try storage.get(key: address.eip55Description) else {
            throw Error.wrongAddress
        }

        // 2. Decrypt the ciphertext
        let privateKey = try decrypt.decryptPrivateKey(address.eip55Description, cipherText: ciphertext)

        // 3. Return the wallet representation of the private key
        return EthereumWallet(privateKey: privateKey)
    }
}

extension EthereumAccount {

    public func revealPrivateKey() throws -> ByteArray {
        let privateKey = try decryptWallet()
        return privateKey.privateKey.rawBytes
    }

    public func signDigest(_ digest: ByteArray) throws -> Signature {
        let privateKey = try decryptWallet()
        return try sign(digest, privateKey: privateKey.privateKey)
    }
}
