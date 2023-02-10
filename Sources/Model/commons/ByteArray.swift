import Foundation

/// Represents an array of bytes
public typealias ByteArray = [UInt8]

/// Represents an array of bytes in hex format
public extension ByteArray {
    var hex: String {
        "\(self.toHexString().withPrefix)"
    }
}
