import Foundation
import class Model.HDWallet
import typealias Model.ByteArray
import MnemonicSwift

public final class EthereumSeedPhrase {

    private let hdWallet: HDWallet

    public enum Error: Swift.Error {
        case retrieveSeedBytes
    }

    /// Creates a new EthereumSeedPhrase with the given mnemonic string
    /// - Parameter seed: The seed in bytes format
    public init(mnemonic: String) throws {
        let deterministicSeed: ByteArray = try Mnemonic.deterministicSeedBytes(from: mnemonic)
        self.hdWallet = try HDWallet(seed: deterministicSeed)
    }
}
