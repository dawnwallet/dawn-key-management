import Foundation
import CryptoSwift

import typealias Model.ByteArray
import struct Model.EthereumPublicKey
import class Model.EthereumPrivateKey

public final class HDNodePrivateKey {

    private let key: EthereumPrivateKey
    private let chainCode: ByteArray
    private let depth: UInt32
    private let parentFingerprint: UInt32
    private let childNumber: UInt32

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

    internal var data: Data {
        Data(key.rawBytes)
    }
}

//MARK: - Public Key
extension HDNodePrivateKey {
    public func publicKey(compressed: Bool) throws -> EthereumPublicKey {
        try key
            .publicKey(compressed: compressed)
    }
}

//MARK: - Derive functions
extension HDNodePrivateKey {

    func derivePath() throws -> HDNodePrivateKey {
        // TODO: Injecting an actual BIP39 address path instead of hardcoding the ethereum one
        try self
            .deriveChild(44, hardened: true)
            .deriveChild(60, hardened: true)
            .deriveChild(0, hardened: true)
            .deriveChild(0)
    }

    func deriveChild(_ index: UInt32, hardened: Bool = false) throws -> HDNodePrivateKey {
        let pubKey = try self.publicKey(compressed: true)

        var data = Data()

        if hardened {
            data.append(UInt8(0))
            data.append(key.rawBytes, count: key.rawBytes.count)
        } else {
            data.append(pubKey.data, count: pubKey.data.count)
        }

        let childIndex = (hardened ? (0x8000_0000 | index) : index).bigEndian
        data.append(childIndex.data)

        let hmac = HMAC(key: chainCode.bytes, variant: .sha2(.sha512))
        let digest = try hmac.authenticate(data.bytes)

        let parentKey = digest[0..<32]
        let chainCode = digest[32..<64]

        let childKey = try generateChildKey(privateKey: key.rawBytes, derivedPrivateKey: parentKey)

        return HDNodePrivateKey(
            key: EthereumPrivateKey(rawBytes: childKey),
            chainCode: chainCode.bytes,
            depth: depth + 1,
            parentFingerprint: self.parentFingerprint,
            childNumber: childNumber
        )
    }
}
