import Foundation
import class Model.EthereumPrivateKey
import struct Model.EthereumPublicKey
import struct Model.EthereumAddress

import class Keychain.KeyEncryptor
import class Keychain.KeyDecryptor
import class Keychain.KeyStorage

public class EthereumWallet {

    internal let privateKey: EthereumPrivateKey
    private let encrypt: KeyEncryptor
    private let decrypt: KeyDecryptor
    private let storage: KeyStorage

    convenience init(privateKey: EthereumPrivateKey) {
        self.init(privateKey: privateKey, encrypt: KeyEncryptor(), decrypt: KeyDecryptor(), storage: KeyStorage())
    }

    public init(privateKey: EthereumPrivateKey, encrypt: KeyEncryptor, decrypt: KeyDecryptor, storage: KeyStorage) {
        self.privateKey = privateKey
        self.encrypt = encrypt
        self.decrypt = decrypt
        self.storage = storage
    }

    var publicKey: Model.EthereumPublicKey {
        get throws {
            try privateKey.publicKey(compressed: false)
        }
    }

    var address: Model.EthereumAddress {
        get throws {
            let publicKey = try privateKey
                .publicKey(compressed: false)
            return try EthereumAddress(publicKey: publicKey)
        }
    }
}

// Encryption / Decryption
extension EthereumWallet {
    @discardableResult
    public func encryptWallet() throws -> EthereumWallet {
        let privateKey = Data(privateKey.rawBytes)
        let address = try address.eip55Description

        // 1. Encrypt the private key using the address checksum as reference
        let ciphertext = try encrypt.encrypt(privateKey, with: address)

        // 2. Store the ciphertext in the keychain
        try storage.set(data: ciphertext as Data, key: address)

        return self
    }

    @discardableResult
    public func decryptWallet(with address: String) throws -> EthereumWallet {
        // 1. Get the ciphertext stored in the keychai
        guard let ciphertext = try storage.get(key: address) else {
            throw Error.parseECDSA
        }

        // 2. Decrypt the ciphertext
        let privateKey = try decrypt.decrypt(address, cipherText: ciphertext)

        // 3. Return the wallet representation of the private key
        return EthereumWallet(privateKey: privateKey)
    }
}
