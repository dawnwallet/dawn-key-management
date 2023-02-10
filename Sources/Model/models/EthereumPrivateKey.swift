import Foundation

/// Class (reference) instead of Struct (
public final class EthereumPrivateKey {

    enum Constants {
        static var secp256k1Size = 65
    }

    public enum KeyError: Swift.Error {
        case generatingPublicKey
        case privateKeyContext
    }

    public let rawBytes: [UInt8]

    /// Creates a new EthereumPrivateKey with the given byte array
    /// - Parameter rawBytes: The pruvate key bytes
    public init(rawBytes: [UInt8]) {
        self.rawBytes = rawBytes
        /// Closure called to return the pointer of the contiguous block of memory for the raw bytes.
        let _ = self.rawBytes.withUnsafeBufferPointer { pointer in
            /// Lock the selected region of address space, starting from the first element of the buffer from the pointer
            /// https://man7.org/linux/man-pages/man2/mlock.2.html
            mlock(pointer.baseAddress, pointer.count)
        }
    }
    deinit {
        /// Closure used to return the pointer of the contiguous storage for the raw bytes.
        self.rawBytes.withUnsafeBufferPointer { (pointer) -> Void in
            /// Unlock the selected region of address space, starting from the first element of the buffer from the pointer
            /// https://man7.org/linux/man-pages/man2/mlock.2.html
            munlock(pointer.baseAddress, pointer.count)
        }
    }
}
