import Foundation
import Model
import Keychain

public class EthereumWallet {

    internal let privateKey: EthereumPrivateKey
    private let encrypt: KeyEncryptor
    private let storage: KeyStorage

    public convenience init(privateKey: EthereumPrivateKey) {
        self.init(privateKey: privateKey, encrypt: KeyEncryptor(), storage: KeyStorage())
    }

    private init(privateKey: EthereumPrivateKey, encrypt: KeyEncryptor, storage: KeyStorage) {
        self.privateKey = privateKey
        self.encrypt = encrypt
        self.storage = storage
    }

    var publicKey: Model.EthereumPublicKey {
        get throws {
            try privateKey.publicKey(compressed: false)
        }
    }

    public var address: Model.EthereumAddress {
        get throws {
            let publicKey = try privateKey
                .publicKey(compressed: false)
            return try EthereumAddress(publicKey: publicKey)
        }
    }
}

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
}
