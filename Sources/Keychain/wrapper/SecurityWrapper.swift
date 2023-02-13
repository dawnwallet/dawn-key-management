import Foundation
import Security

public protocol SecurityWrapper {
    func SecKeyCopyPublicKey(_ key: SecKey) -> SecKey?
    func SecKeyCreateEncryptedData(_ key: SecKey, _ algorithm: SecKeyAlgorithm, _ plaintext: CFData, _ error: UnsafeMutablePointer<Unmanaged<CFError>?>?) -> CFData?
    func SecItemCopyMatching(_ query: CFDictionary, _ result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus
    func SecKeyCreateRandomKey(_ parameters: CFDictionary, _ error: UnsafeMutablePointer<Unmanaged<CFError>?>?) -> SecKey?
}

/// Security wrapper used to easily unit test any interaction with the Keychain
final class SecurityWrapperImp: SecurityWrapper {

    func SecKeyCopyPublicKey(_ key: SecKey) -> SecKey? {
        return Security.SecKeyCopyPublicKey(key)
    }

    func SecKeyCreateEncryptedData(_ key: SecKey, _ algorithm: SecKeyAlgorithm, _ plaintext: CFData, _ error: UnsafeMutablePointer<Unmanaged<CFError>?>?) -> CFData? {
        Security.SecKeyCreateEncryptedData(key, algorithm, plaintext, error)
    }

    func SecItemCopyMatching(_ query: CFDictionary, _ result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus {
        Security.SecItemCopyMatching(query, result)
    }

    func SecKeyCreateRandomKey(_ parameters: CFDictionary, _ error: UnsafeMutablePointer<Unmanaged<CFError>?>?) -> SecKey? {
        Security.SecKeyCreateRandomKey(parameters, error)
    }
}
