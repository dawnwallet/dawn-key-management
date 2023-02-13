import CryptoSwift

public final class HDWallet {

    private let key: ByteArray
    private let chainCode: ByteArray
    private let depth: UInt32
    private let parentFingerprint: UInt32
    private let childNumber: UInt32

    enum Error: Swift.Error {
        case privateKeyContext
    }

    /// Creates a new HDWallet with the given seed bytes
    /// - Parameter seed: The seed in bytes format
    public init(seed: ByteArray) throws {
        let hmac = HMAC(key: "Bitcoin seed".data(using: .ascii)!.bytes, variant: .sha2(.sha512))
        let output = try! hmac.authenticate(seed)
        self.key = ByteArray(output[0..<32])
        self.chainCode = ByteArray(output[32..<64])
        self.depth = 0
        self.parentFingerprint = 0
        self.childNumber = 0
    }

    private init(
        key: ByteArray,
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
}
