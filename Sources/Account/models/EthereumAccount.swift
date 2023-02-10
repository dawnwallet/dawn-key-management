import Foundation

/**
 *  An account handles storing, updating, loading and removing either you private key account or your seed phrase one.
 *  We differ between both to avoid fetching all seed phrases in case we want to derive a single wallet. Any derived wallet is stored as PrivateKeyAccount
 *  EthereumAccount stores all its accounts in a directory located at **accounts**
*/
public final class EthereumAccount: Identifiable {

    public let walletDirectory: WriterDirectory

    public enum Error: Swift.Error {
        case fetchingSelectedWallet
        case importingMnemonic
    }

    public init(walletDirectory: WriterDirectory = WalletWriterDirectory(fileSubfolder: "accounts/")) {
        self.walletDirectory = walletDirectory
    }
}

/// Seed Phrase Account methods
extension EthereumAccount {

    public func fetchSeedPhraseAccounts() throws -> [SeedPhraseAccount?] {
        let seedPhraseAccount: [SeedPhraseAccount?] = try walletDirectory.retrieve(
            objectType: SeedPhraseAccount.self
        )
        return seedPhraseAccount
    }
}

/// Private Key Account methods
extension EthereumAccount {
    public func fetchPrivateKeyAccounts() throws -> [PrivateKeyAccount?] {
        let privateKeyAccount: [PrivateKeyAccount?] = try walletDirectory.retrieve(
            objectType: PrivateKeyAccount.self
        )
        return privateKeyAccount
    }

    public func fetchPrivateKeyAccount(_ address: String) throws -> PrivateKeyAccount? {
        let privateKeyAccount: [PrivateKeyAccount?] = try walletDirectory.retrieve(
            objectType: PrivateKeyAccount.self
        )
        return privateKeyAccount
            .compactMap { $0 }
            .first { $0.eip55Address == address }
    }

    public func deletePrivateKeyAccount(_ account: PrivateKeyAccount) throws {
        try walletDirectory.delete(at: account.eip55Address)
    }
}

extension EthereumAccount {
    public func deleteAll() throws {
        try walletDirectory.deleteAll()
    }
}
