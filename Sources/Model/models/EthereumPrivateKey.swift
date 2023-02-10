import Foundation

public final class EthereumPrivateKey {

    enum Constants {
        static var secp256k1Size = 65
    }

    enum KeyError: Swift.Error {
        case generatingPublicKey
        case privateKeyContext
    }

    internal let rawBytes: ByteArray

    public init(rawBytes: ByteArray) {
        self.rawBytes = rawBytes
        let _ = self.rawBytes.withUnsafeBufferPointer { pointer in
            mlock(pointer.baseAddress, pointer.count)
        }
    }

    deinit {
        self.rawBytes.withUnsafeBufferPointer { (pointer) -> Void in
            munlock(pointer.baseAddress, pointer.count)
        }
    }
}
