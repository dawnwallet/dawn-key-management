import Foundation
import Model
import class Model.EthereumPrivateKey

public protocol KeyDecrypting {
    func decryptSeed(_ id: String, cipherText: Data) throws -> ByteArray
    func decryptPrivateKey(_ address: String, cipherText: Data) throws -> EthereumPrivateKey
}

public final class KeyDecryptor: KeyDecrypting {

    public init() { }

    public func decryptSeed(_ id: String, cipherText: Data) throws -> ByteArray {
        let decryptedBytes = try decrypt(id, cipherText: cipherText)
        return decryptedBytes
    }

    public func decryptPrivateKey(_ address: String, cipherText: Data) throws -> EthereumPrivateKey {
        let decryptedBytes = try decrypt(address, cipherText: cipherText)
        return EthereumPrivateKey(rawBytes: decryptedBytes)
    }

    private func decrypt(_ id: String, cipherText: Data) throws -> ByteArray {
        // 1. Get the reference of the secret stored in the secure enclave
        let secret = try secretReference(with: id, cipherText: cipherText)

        // 2. Decrypt privateKey using the secret reference, and ciphertext
        var error: Unmanaged<CFError>?
        let plainTextData = SecKeyCreateDecryptedData(secret as! SecKey, Constants.algorithm, cipherText as CFData, &error) as Data?

        // 3. Return the Private Key using the array of bytes
        return plainTextData!.bytes
    }

    private func secretReference(with reference: String, cipherText: Data) throws -> CFTypeRef? {
        let params: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrApplicationTag as String: reference.data(using: .utf8) as Any,
            kSecAttrAccessGroup as String: Constants.accessGroup,
            kSecReturnRef as String: true,
        ]
        var raw: CFTypeRef?
        let status = Security.SecItemCopyMatching(params as CFDictionary, &raw)
//        guard status == errSecSuccess else { throw  }
        return raw
    }
}
