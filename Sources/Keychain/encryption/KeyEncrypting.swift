import Foundation

public protocol KeyEncrypting {
    func encrypt(_ privateKey: Data, with reference: String) throws -> CFData
}

public final class KeyEncryptor: KeyEncrypting {

    private let security: SecurityWrapper

    public convenience init() {
        self.init(security: SecurityWrapperImp())
    }

    init(security: SecurityWrapper) {
        self.security = security
    }

    enum Error: Swift.Error {
        case referenceNotFound
        case unexpectedStatus(OSStatus)
        case invalidFormat
        case publicKey
        case failedEncryption
        case resolvingPublicKey
    }

    /// Encrypt the private key using a secret generated in the secure enclave
    /// - Parameters:
    ///   - privateKey: Private key
    ///   - reference: Reference used to place the generated secret
    /// - Returns: Ciphertext
    public func encrypt(_ privateKey: Data, with reference: String) throws -> CFData {
        let secretReference: SecKey
        do {
            // 1. Check if there is a secret stored in the secure enclave using the address as tag (tag is not involved in the encryption process, it's used only to fetch the secret reference)
            // Value returned is the reference used to interact with the secure enclave. The secret itself never gets exposed.
            secretReference = try retrieveSecret(with: reference)
        } catch {
            // 2. If not, a secret using the address as tag is generated
            secretReference = try generateSecret(with: reference)
        }

        // 3. Resolve the public key using the reference retrieved / generated before
        guard let publicKey = security.SecKeyCopyPublicKey(secretReference) else {
            throw Error.resolvingPublicKey
        }

        // 4. Encrypt the private key data using the secret reference applying the eciesEncryptionCofactorVariableIVX963SHA256AESGCM algorithm
        var encryptionError: Unmanaged<CFError>?
        guard let ciphertext = security.SecKeyCreateEncryptedData(publicKey, Constants.algorithm, privateKey as CFData, &encryptionError) else {
            throw Error.failedEncryption
        }

        return ciphertext
    }

    /// Fetch the reference of the secret, throw an error in case it does not exist
    private func retrieveSecret(with reference: String) throws -> SecKey {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrApplicationTag as String: reference.data(using: .utf8) as Any,
            kSecAttrAccessGroup as String: "",
            kSecReturnRef as String: true,
        ]

        // SecItemCopyMatching will attempt to copy the secret reference identified by the query to the reference secretRef
        var secretRef: CFTypeRef?
        let status = security.SecItemCopyMatching(
            query as CFDictionary,
            &secretRef
        )

        // In case the expected secret does not exist, we throw a referenceNotFound error
        guard status != errSecItemNotFound else {
            throw Error.referenceNotFound
        }

        // Other than success, we throw an error with the error status
        guard status == errSecSuccess else {
            throw Error.unexpectedStatus(status)
        }

        return secretRef as! SecKey
    }

    /// Generate secret in the secure enclave, then return its reference
    private func generateSecret(with reference: String) throws -> SecKey {
        var error: Unmanaged<CFError>?
        let query = secretQuery(with: reference)
        guard let secKey = security.SecKeyCreateRandomKey(query as CFDictionary, &error) else {
            throw error!.takeRetainedValue() as Swift.Error
        }
        return secKey
    }

    /// Query used to generate the secret
    private func secretQuery(with reference: String) -> [String: Any] {
        let access = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            [.privateKeyUsage],
            nil
        )
        let result: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeEC,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecAttrAccessGroup as String: Constants.accessGroup,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: reference.data(using: .utf8) as Any,
                kSecAttrAccessControl as String: access as Any,
            ],
        ]
        return result
    }
}
