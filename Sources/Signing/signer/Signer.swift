import Foundation
import secp256k1

import typealias Model.Signature
import typealias Model.ByteArray
import class Model.EthereumPrivateKey

enum Error: Swift.Error {
    case memoryBound
    case createContext
    case parseECDSA
}

public protocol Signer {
    var rawBytes: ByteArray { get }
    func sign(_ _hash: ByteArray) throws -> Signature
}

extension EthereumPrivateKey: Signer { }

public extension Signer where Self: EthereumPrivateKey {

    func sign(_ digest: ByteArray) throws -> Signature {
        // Mutable hash
        var hash = digest

        // 1. The contiguous memory footprint of the ECDSA signature
        let ecdsaMemory = MemoryLayout<secp256k1_ecdsa_recoverable_signature>.size

        // 2. We allocate any necessary storage, malloc returns a pointer to a newly allocated memory
        let ecdsaMemoryStorage = malloc(ecdsaMemory)

        // 3. We return a typed pointer to the memory we've bound to the ECDSA signature type
        guard let signaturePointer = ecdsaMemoryStorage?.assumingMemoryBound(to: secp256k1_ecdsa_recoverable_signature.self) else {
            throw Error.memoryBound
        }

        // 4. Create a secp256k1 context object, internally it uses malloc to allocate its memory.
        guard let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY)) else {
            throw Error.createContext
        }

        // 5. Defer executes code just before transferring program control outside of the scope. In case this happens, we free the allocated storage of the ECDSA signature, and destroy the context object
        defer {
            secp256k1_context_destroy(context)
            free(signaturePointer)
        }

        // 6. Create a recoverable ECDSA signature (64 bytes + recovery id)
        // secp256k1_ecdsa_sign_recoverable will place the signature at signaturePointer. signaturePointer will hold a parsed ECDSA signature.
        // Returns: 1 == signature created; 0 == generation function failed
        guard secp256k1_ecdsa_sign_recoverable(context, signaturePointer, &hash, rawBytes, nil, nil) == 1 else {
            throw Error.parseECDSA
        }

        // Serialize an ECDS signature in compact format (64 bytes + recovery id).
        let signature = serialize(context: context, recoverableSignature: signaturePointer)

        return signature
    }

    private func serialize(context: OpaquePointer, recoverableSignature: UnsafeMutablePointer<secp256k1_ecdsa_recoverable_signature>) -> Signature {
        var signature = ByteArray(repeating: 0, count: 65)
        var recid: Int32 = 0

        secp256k1_ecdsa_recoverable_signature_serialize_compact(context, &signature, &recid, recoverableSignature)

        return Signature(v: UInt(recid), r: Array(signature[0..<32]), s: Array(signature[32..<64]))
    }
}
