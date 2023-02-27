import Foundation
import Security

public protocol SecurityWrapper {
    func SecItemDelete(_ query: CFDictionary) -> OSStatus
    func SecKeyCreateDecryptedData(_ key: SecKey, _ algorithm: SecKeyAlgorithm, _ ciphertext: CFData, _ error: UnsafeMutablePointer<Unmanaged<CFError>?>?) -> CFData?
    func SecItemAdd(_ attributes: CFDictionary, _ result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus
    func SecKeyCopyPublicKey(_ key: SecKey) -> SecKey?
    func SecKeyCreateEncryptedData(_ key: SecKey, _ algorithm: SecKeyAlgorithm, _ plaintext: CFData, _ error: UnsafeMutablePointer<Unmanaged<CFError>?>?) -> CFData?
    func SecItemCopyMatching(_ query: CFDictionary, _ result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus
    func SecKeyCreateRandomKey(_ parameters: CFDictionary, _ error: UnsafeMutablePointer<Unmanaged<CFError>?>?) -> SecKey?
}

/// Security wrapper used to easily unit test any interaction with the Keychain
public final class SecurityWrapperImp: SecurityWrapper {

    public func SecItemDelete(_ query: CFDictionary) -> OSStatus {
        Security.SecItemDelete(query)
    }

    public func SecKeyCreateDecryptedData(_ key: SecKey, _ algorithm: SecKeyAlgorithm, _ ciphertext: CFData, _ error: UnsafeMutablePointer<Unmanaged<CFError>?>?) -> CFData? {
        Security.SecKeyCreateDecryptedData(key, algorithm, ciphertext, error)
    }

    public func SecItemAdd(_ attributes: CFDictionary, _ result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus {
        Security.SecItemAdd(attributes, result)
    }

    public func SecKeyCopyPublicKey(_ key: SecKey) -> SecKey? {
        Security.SecKeyCopyPublicKey(key)
    }

    public func SecKeyCreateEncryptedData(_ key: SecKey, _ algorithm: SecKeyAlgorithm, _ plaintext: CFData, _ error: UnsafeMutablePointer<Unmanaged<CFError>?>?) -> CFData? {
        Security.SecKeyCreateEncryptedData(key, algorithm, plaintext, error)
    }

    public func SecItemCopyMatching(_ query: CFDictionary, _ result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus {
        Security.SecItemCopyMatching(query, result)
    }

    public func SecKeyCreateRandomKey(_ parameters: CFDictionary, _ error: UnsafeMutablePointer<Unmanaged<CFError>?>?) -> SecKey? {
        Security.SecKeyCreateRandomKey(parameters, error)
    }
}
