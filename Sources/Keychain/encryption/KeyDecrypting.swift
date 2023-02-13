import Foundation
import class Model.EthereumPrivateKey

protocol KeyDecrypting {
    func decrypt(_ address: String, cipherText: Data) throws -> EthereumPrivateKey
}

final class KeyDecryptor: KeyDecrypting {
    public func decrypt(_ address: String, cipherText: Data) throws -> EthereumPrivateKey {
        // 1. Get the reference of the secret stored in the secure enclave
        let secret = try secretReference(with: address, cipherText: cipherText)

        // 2. Decrypt privateKey using the secret reference, and ciphertext
        var error: Unmanaged<CFError>?
        let plainTextData = SecKeyCreateDecryptedData(secret as! SecKey, Constants.algorithm, cipherText as CFData, &error) as Data?

        // 3. Return the Private Key using the array of bytes
        return EthereumPrivateKey(rawBytes: plainTextData!.bytes)
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
