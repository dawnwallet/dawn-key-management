import Foundation
import class Model.EthereumPrivateKey
import struct Model.EthereumPublicKey
import secp256k1

/// Generate the Public Key from the Private Key
extension EthereumPrivateKey {
    func publicKey(compressed: Bool) throws -> EthereumPublicKey {
        /// Create a secp256k1 context object (in dynamically allocated memory)
        guard let context = secp256k1_context_create(
            UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY)),
              secp256k1_ec_seckey_verify(context, rawBytes) == 1
        else { throw KeyError.privateKeyContext }

        /// Destroy the secp256k1 context object, just before exiting the scope
        defer {
            secp256k1_context_destroy(context)
        }

        /// Initializing memory pointer specifically for secp256k1_pubkey + destroy after
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
