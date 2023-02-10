import Foundation
import class CryptoSwift.SHA3

public extension SHA3 {
    static func keccak256(data: ByteArray) -> ByteArray {
        SHA3(variant: .keccak256).calculate(for: data)
    }
}
