import Foundation

public protocol KeyDeletable {
    func delete(with reference: String) throws -> OSStatus
}

public final class KeyDeleting: KeyDeletable {

    private let security: SecurityWrapper
    private let keyStore: KeyStorage

    public convenience init() {
        self.init(security: SecurityWrapperImp(), keyStore: KeyStorage())
    }

    private init(security: SecurityWrapper, keyStore: KeyStorage) {
        self.security = security
        self.keyStore = keyStore
    }

    @discardableResult
    public func delete(with reference: String) throws -> OSStatus {
        let params: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrApplicationTag as String: reference.data(using: .utf8) as Any,
        ]
        // 1. Delete the ciphertext stored at reference
        try keyStore.delete(key: reference)

        // 2. Delete the secret used to encrypt the ciphertext
        return security.SecItemDelete(params as CFDictionary)
    }
}
