import Foundation

public typealias ByteArray = [UInt8]

public extension ByteArray {
    var hex: String {
        "\(self.toHexString().withPrefix)"
    }
}

extension ByteArray {
    @discardableResult
    public func withDecryptedBytes<R>(_ content: (ByteArray) throws -> R) rethrows -> R {
        // 1. Calls out a pointer to the underlying bytes of the array's decrypted contiguous storage
        let result = try self.withUnsafeBytes { pointer -> R in
            // 2. A mutable raw pointer for accessing and manipulating untyped data. We need to manipulate in order to call memset_s method. Lock the selected region of the mutable raw pointer
            let mutablePointer = UnsafeMutableRawPointer(mutating: pointer.baseAddress!)
            mlock(mutablePointer, pointer.count)
            // 3 When the current scope exits, we zero out the pointer, and unlock it
            defer {
                memset_s(mutablePointer, pointer.count, 0, pointer.count)
                munlock(mutablePointer, pointer.count)
            }
            return try content(self)
        }
        return result
    }
}
