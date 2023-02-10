import Foundation

public final class EthereumPrivateKey {

    enum Constants {
        static var secp256k1Size = 65
    }

    public enum KeyError: Swift.Error {
        case generatingPublicKey
        case privateKeyContext
    }

    public let rawBytes: [UInt8]

    public init(rawBytes: [UInt8]) {
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
