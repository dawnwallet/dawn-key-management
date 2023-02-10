import Foundation
import struct Model.EthereumAddress

public final class PrivateKeyAccount: Codable {

    public let eip55Address: String
    public let cipherText: Data

    public init(
        eip55Address: String,
        cipherText: Data
    ) {
        self.eip55Address = eip55Address
        self.cipherText = cipherText
    }
}
