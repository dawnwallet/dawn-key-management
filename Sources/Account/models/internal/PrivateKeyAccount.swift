import Foundation
import struct Model.EthereumAddress

/**
 *  A PrivateKeyAccount repesents an object associated with a Private Key.
*/
public final class PrivateKeyAccount: Codable {

    public let eip55Address: String

    public init(eip55Address: String) {
        self.eip55Address = eip55Address
    }
}
