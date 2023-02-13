import Foundation
import class Model.EthereumPrivateKey
import struct Model.EthereumPublicKey
import struct Model.EthereumAddress

public struct EthereumWallet {

    private let privateKey: EthereumPrivateKey

    init(privateKey: EthereumPrivateKey) {
        self.privateKey = privateKey
    }

    var publicKey: EthereumPublicKey {
        get throws {
            try privateKey.publicKey(compressed: false)
        }
    }

    var address: EthereumAddress {
        get throws {
            let publicKey = try privateKey
                .publicKey(compressed: false)
            return try EthereumAddress(publicKey: publicKey)
        }
    }
}
