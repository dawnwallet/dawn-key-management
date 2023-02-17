import Foundation
import class Model.EthereumPrivateKey
import struct Model.EthereumPublicKey
import secp256k1

extension EthereumPrivateKey {

    func publicKey(compressed: Bool) throws -> EthereumPublicKey {

        // 1. Create a secp256k1 context object, internally it uses malloc to allocate its memory.
        guard let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_VERIFY)),
              secp256k1_ec_seckey_verify(context, rawBytes) == 1 else {
            throw KeyError.privateKeyContext
        }

        // 2. Defer executes code just before transferring program control outside of the scope. In case this happens, we destroy the context object
        defer {
            secp256k1_context_destroy(context)
        }

        let publicKeyPointer = UnsafeMutablePointer<secp256k1_pubkey>.allocate(capacity: 1)
        defer { publicKeyPointer.deallocate() }

        var outputLen: Int = compressed ? 33 : 65

        let publicKeyOutputPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: outputLen)
        defer { publicKeyOutputPointer.deallocate() }

        /// Generate the Public Key
        guard secp256k1_ec_pubkey_create(context, publicKeyPointer, rawBytes) == 1 else {
            throw KeyError.generatingPublicKey
        }

        /// Serialize the Public Key uncompressed using an output pointer, getting the Data version of it, then returning the bytes
        let compressedFlags = compressed ? UInt32(SECP256K1_EC_COMPRESSED) : UInt32(SECP256K1_EC_UNCOMPRESSED)
        secp256k1_ec_pubkey_serialize(
            context,
            publicKeyOutputPointer,
            &outputLen,
            publicKeyPointer,
            compressedFlags
        )
        var publicKey = Data(bytes: publicKeyOutputPointer, count: outputLen)
        if !compressed {
            publicKey.remove(at: 0)
        }
        let publicKeyBytes = publicKey.bytes
        return EthereumPublicKey(rawBytes: publicKeyBytes)
    }
}
