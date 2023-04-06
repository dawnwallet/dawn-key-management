import Foundation

public protocol KeyStoring {
    func set(data: Data, key: String) -> OSStatus
    func get(key: String) throws -> Data?
    func delete(key: String) -> OSStatus
}

public final class KeyStorage: KeyStoring {

    private let security: SecurityWrapper

    enum Error: Swift.Error {
        case deleteStorage
    }

    public convenience init() {
        self.init(security: SecurityWrapperImp())
    }

    private init(security: SecurityWrapper) {
        self.security = security
    }

    @discardableResult
    public func set(data: Data, key: String) -> OSStatus {
        // 1. Delete any existing key before saving it
        let status = delete(key: key)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            return status
        }

        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ] as [String : Any]

        // 2. Save item into the keychain
        return security.SecItemAdd(query as CFDictionary, nil)
    }

    public func get(key: String) throws -> Data? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String : Any]

        var dataTypeRef: AnyObject?
        let status: OSStatus = security.SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr {
            return dataTypeRef as? Data
        } else {
            return nil
        }
    }

    @discardableResult
    public func delete(key: String) -> OSStatus {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key
        ] as [String: Any]

        return security.SecItemDelete(query as CFDictionary)
    }
}
