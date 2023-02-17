import Foundation
import class Model.EthereumPrivateKey

import class Model.HDEthereumPrivateKey

import typealias Model.ByteArray
import secp256k1

extension HDEthereumPrivateKey {
    func generateChildKey(
        privateKey: ByteArray,
        derivedPrivateKey: ArraySlice<UInt8>
    ) throws -> ByteArray {
        // Mutable privateKey
        var rawVariable = privateKey

        // 1. Create a secp256k1 context object, internally it uses malloc to allocate its memory.
        guard let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_VERIFY)) else {
            throw EthereumPrivateKey.KeyError.privateKeyContext
        }

        // 2. Defer executes code just before transferring program control outside of the scope. In case this happens, we destroy the context object
        defer { secp256k1_context_destroy(context) }

        // 4. Get access of the underlying pointer of the private key, as required for secp256k1_ec_privkey_tweak_add function
        let status = rawVariable.withUnsafeMutableBytes { privateKeyBytes -> Int32 in
            // 5. We typed the returned pointer
            guard let privateKeyPointer = privateKeyBytes.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return 0 }
            return secp256k1_ec_seckey_tweak_add(context, privateKeyPointer, derivedPrivateKey.bytes)
        }

        // 6. Throw an error in case status is not true
        guard status == 1 else { throw EthereumAccount.Error.memoryBound }
        return rawVariable
    }
}
