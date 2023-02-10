import Foundation
import class CryptoSwift.SHA3

public struct EthereumPublicKey {

    enum Constants {
        static let secp256k1Size = 64
    }

    private let rawBytes: ByteArray

    public init(rawBytes: ByteArray) {
        self.rawBytes = rawBytes
    }

    public func isValid() -> Bool {
        if rawBytes.count == 0 { return false }
        return rawBytes.count == Constants.secp256k1Size
    }

    public func addressBytes() -> ByteArray? {
        let hash = SHA3.keccak256(data: rawBytes)

        guard hash.count == 32 else {
            return nil
        }
        return Array(hash[12...])
    }

    public var data: ByteArray {
        rawBytes
    }
}
