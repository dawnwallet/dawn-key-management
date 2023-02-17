import Foundation

public final class HDEthereumPrivateKey {

    public let key: EthereumPrivateKey
    public let chainCode: ByteArray
    public let depth: UInt32
    public let parentFingerprint: UInt32
    public let childNumber: UInt32

    public init(
        key: EthereumPrivateKey,
        chainCode: ByteArray,
        depth: UInt32,
        parentFingerprint: UInt32,
        childNumber: UInt32
    ) {
        self.key = key
        self.chainCode = chainCode
        self.depth = depth
        self.parentFingerprint = parentFingerprint
        self.childNumber = childNumber
    }

    public var data: Data {
        Data(key.rawBytes)
    }
}
