import Foundation

/**
 *  An account handles storing, updating, loading and removing either your private key account or your seed phrase.
 *  We differ between both to avoid fetching all seed phrases in case we want to derive a new wallet. Any new private key is also stored as PrivateKeyAccount
 *  EthereumAccount stores all its accounts in a directory called **accounts**
*/
public final class EthereumAccount: Identifiable {

    public let walletDirectory: WriterDirectory

    public init(walletDirectory: WriterDirectory) {
        self.walletDirectory = walletDirectory
    }
}

extension EthereumAccount {
    public func insert(account: Codable, at location: String) throws {
        try walletDirectory.write(account, at: location)
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
