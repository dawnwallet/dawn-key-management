import Foundation

public struct SeedPhraseAccount: Codable {
    public let id: String
    public let addresses: [Int: String]
    public let cipherText: Data

    public init(id: String, addresses: [Int: String], cipherText: Data) {
        self.id = id
        self.addresses = addresses
        self.cipherText = cipherText
    }
}
