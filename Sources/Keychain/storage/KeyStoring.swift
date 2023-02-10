import Foundation

protocol KeyStoring {
    func set(data: Data, key: String) -> OSStatus
    func get(key: String) -> Data?
}

final class KeyStorage: KeyStoring {

    func set(data: Data, key: String) -> OSStatus {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ] as [String : Any]

        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil)
    }

    func get(key: String) -> Data? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String : Any]

        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr {
            return dataTypeRef as! Data?
        } else {
            return nil
        }
    }
}
