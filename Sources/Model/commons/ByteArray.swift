import Foundation

public typealias ByteArray = [UInt8]

public extension ByteArray {
    var hex: String {
        "\(self.toHexString().withPrefix)"
    }
}
