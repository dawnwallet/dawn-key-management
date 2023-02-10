import Foundation
import CryptoSwift

public extension SHA3 {
    static func keccak256(data: ByteArray) -> ByteArray {
        SHA3(variant: .keccak256).calculate(for: data)
    }
}
