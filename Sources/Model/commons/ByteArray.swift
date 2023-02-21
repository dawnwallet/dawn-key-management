import Foundation

public typealias ByteArray = [UInt8]

public extension ByteArray {
    var hex: String {
        "\(self.toHexString().withPrefix)"
    }
}

extension ByteArray {
    @discardableResult
    public func withDecryptedBytes<T>(_ content: (ByteArray) throws -> T) rethrows -> T {

        // 2. Calls out a pointer to the underlying bytes of the array's decrypted contiguous storage
        let result = try self.withUnsafeBytes { pointer -> T in
            // 3. A mutable raw pointer for accessing and manipulating untyped data. We need to manipulate it to call memset_s method. Lock the selected region of the mutable raw pointer
            let mutablePointer = UnsafeMutableRawPointer(mutating: pointer.baseAddress!)
            mlock(mutablePointer, pointer.count)

            // 4 When the current scope exits, we zero out the pointer, and unlock it
            defer {
                memset_s(mutablePointer, pointer.count, 0, pointer.count)
                munlock(mutablePointer, pointer.count)
            }

            return try content(self)
        }
        return result
    }
}
