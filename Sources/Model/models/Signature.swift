import Foundation

public typealias ByteArray = [UInt8]
public typealias Signature = (r: ByteArray, s: ByteArray, v: UInt)

/// Convert array of bytes to hex string
public extension ByteArray {
    var hex: String {
        "\(self.toHexString().withPrefix)"
    }
}
