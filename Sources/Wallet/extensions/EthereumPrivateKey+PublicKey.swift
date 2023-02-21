import Foundation
import class Model.EthereumPrivateKey
import class Model.EthereumPublicKey
import secp256k1

extension EthereumPrivateKey {

    func publicKey(compressed: Bool) throws -> EthereumPublicKey {

        // 1. The contiguous memory footprint of the secp256k1_pubkey
        let publicKeyMemory = MemoryLayout<secp256k1_pubkey>.size

        // 2. We allocate any necessary storage, malloc returns a pointer to a newly allocated memory
        let publicKeyMemoryStorage = malloc(publicKeyMemory)

        // 3. We return a typed pointer to the memory we've bound to the ECDSA signature type
        guard let publicKeyPointer = publicKeyMemoryStorage?.assumingMemoryBound(to: secp256k1_pubkey.self) else {
            throw EthereumAccount.Error.memoryBound
        }

        // 4. Create a secp256k1 context object, internally it uses malloc to allocate its memory.
        guard let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_VERIFY)),
              secp256k1_ec_seckey_verify(context, rawBytes) == 1 else {
            throw KeyError.privateKeyContext
        }

        // 5. Defer executes code just before transferring program control outside of the scope. In case this happens, we destroy the context object
        defer {
            secp256k1_context_destroy(context)
            free(publicKeyPointer)
        }

        // 6. Computes the public key from private key
        guard secp256k1_ec_pubkey_create(context, publicKeyPointer, rawBytes) == 1 else {
            throw KeyError.generatingPublicKey
        }

        // 7. Serialize the Public Key
        return try serialize(context: context, compressed: compressed, publicKeyPointer: publicKeyPointer)
    }

    private func serialize(
        context: OpaquePointer,
        compressed: Bool,
        publicKeyPointer: UnsafeMutablePointer<secp256k1_pubkey>
    ) throws -> EthereumPublicKey {
        var outputLen: Int = compressed ? 33 : 65
        let publicKeyOutputPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: outputLen)

        defer { publicKeyOutputPointer.deallocate() }

        let compressedFlags = compressed ? UInt32(SECP256K1_EC_COMPRESSED) : UInt32(SECP256K1_EC_UNCOMPRESSED)
        secp256k1_ec_pubkey_serialize(
            context,
            publicKeyOutputPointer,
            &outputLen,
            publicKeyPointer,
            compressedFlags
        )
        var publicKey = Data(bytes: publicKeyOutputPointer, count: outputLen)
        if !compressed { publicKey.remove(at: 0) }
        let publicKeyBytes = publicKey.bytes
        return EthereumPublicKey(rawBytes: publicKeyBytes)
    }
}
