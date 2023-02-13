import Foundation

public final struct EthereumWallet {

    private let privateKey: EthereumPrivateKey

    init(privateKey: EthereumPrivateKey) {
        self.privateKey = privateKey
    }

    var publicKey: EthereumPublicKey {
        privateKey.publicKey(compressed: false)
    }

    var address: EthereumAddress {
        let publicKey = try privateKey
            .publicKey(compressed: false)
        return try EthereumAddress(publicKey: publicKey)
    }
}
