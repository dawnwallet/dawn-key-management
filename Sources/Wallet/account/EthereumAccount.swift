import Foundation
import Model
import Keychain

public final class EthereumAccount {

    enum Error: Swift.Error {
        case wrongAddress
        case memoryBound
        case createContext
        case parseECDSA
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
    public func revealPrivateKey() throws -> ByteArray {
        let privateKey = try decryptWallet()
        return privateKey.privateKey.rawBytes
    }

    public func signDigest(_ digest: ByteArray) throws -> Signature {
        let privateKey = try decryptWallet()
        return try sign(digest, privateKey: privateKey.privateKey)
    }
}

extension EthereumAccount {
    private func decryptWallet() throws -> EthereumWallet {
        // 1. Get the ciphertext stored in the keychain
        guard let ciphertext = try keyStorage.get(key: address.eip55Description) else {
            throw Error.wrongAddress
        }

        // 2. Decrypt the ciphertext
        let privateKey = try keyDecrypt.decryptPrivateKey(address.eip55Description, cipherText: ciphertext)

        // 3. Return the wallet representation of the private key
        return EthereumWallet(privateKey: privateKey)
    }
}
