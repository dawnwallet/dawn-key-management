//import Foundation
//import Commons
//
//public enum ImportType {
//    case privateKey
//    case mnemonic
//    case seed
//}
//
//public final class EthereumAccount: Identifiable {
//
//    public let walletDirectory: StoredDirectory
//    public let selectedDirectory: PersistDirectory
//
//    public enum Error: Swift.Error {
//        case fetchingSelectedWallet
//        case importingMnemonic
//    }
//
//    public init(
//        walletDirectory: StoredDirectory = DirectoryWalletWriterDirectory(fileSubfolder: "keystore/"),
//        selectedDirectory: PersistDirectory = UserDefaultsWalletWriterDirectory()
//    ) {
//        self.walletDirectory = walletDirectory
//        self.selectedDirectory = selectedDirectory
//    }
//}
//
///// Fetch wallets stored in disk
//extension EthereumAccount {
//    public func fetchSeeds() throws -> [SeedKeyStore?] {
//        let seedKeystores: [SeedKeyStore?] = try walletDirectory.retrieve(
//            objectType: SeedKeyStore.self, at: ""
//        )
//        return seedKeystores
//    }
//
//    public func fetchWallets() throws -> [EthereumWallet] {
//        let keyStores: [KeyStore?] = try walletDirectory.retrieve(objectType: KeyStore.self, at: "")
//        return try keyStores.compactMap { try $0?.toWallet() }
//    }
//
//    public func fetch(wallet: String) throws -> EthereumWallet? {
//        let keyStores: [KeyStore?] = try walletDirectory.retrieve(objectType: KeyStore.self, at: "")
//        return try keyStores
//            .compactMap { try $0?.toWallet() }
//            .first { $0.address.eip55Description == wallet }
//    }
//}
//
///// Delete Wallet Methods
//extension EthereumAccount {
//    public func delete(wallet: EthereumWallet) throws {
//        try walletDirectory.delete(at: wallet.address.eip55Description)
//    }
//
//    public func deleteAll() throws {
//        try walletDirectory.deleteAll()
//    }
//}
//
///// Update Wallet Methods
//extension EthereumAccount {
//    public func update(keyStore: KeyStore) throws {
//        try walletDirectory.write(keyStore, at: keyStore.eip55Address)
//    }
//}
//
///// Selected Wallet Methods
//extension EthereumAccount {
//    public func setSelected(wallet: EthereumWallet) throws {
//        try selectedDirectory.write(wallet.address.eip55Description, at: "selectedWallet")
//    }
//
//    public func fetchSelectedWallet() throws -> EthereumWallet? {
//        return try retrieveSelectedEthereumWallet()
//    }
//
//    public func changeName(name: String) throws {
//        guard let walletSelected = try retrieveSelectedKeyStore() else {
//            throw Error.fetchingSelectedWallet
//        }
//        var selectedKeyStore = walletSelected
//        selectedKeyStore.name = name
//        try update(keyStore: selectedKeyStore)
//    }
//
//    private func retrieveSelectedEthereumWallet() throws -> EthereumWallet? {
//        guard let selectedWallets: String = try selectedDirectory.retrieve(
//            objectType: String.self, at: "selectedWallet"
//        ) else { throw Error.fetchingSelectedWallet }
//        let keystores: [KeyStore?] = try walletDirectory.retrieve(objectType: KeyStore.self, at: "selectedWallet")
//        return try keystores
//            .filter({ $0?.eip55Address == selectedWallets })
//            .compactMap { try $0?.toWallet() }
//            .first
//    }
//
//    private func retrieveSelectedKeyStore() throws -> KeyStore? {
//        guard let selectedWallets: String = try selectedDirectory.retrieve(
//            objectType: String.self, at: "selectedWallet"
//        ) else { throw Error.fetchingSelectedWallet }
//        let keystores: [KeyStore?] = try walletDirectory.retrieve(objectType: KeyStore.self, at: "")
//        return keystores
//            .filter({ $0?.eip55Address == selectedWallets })
//            .compactMap { $0 }
//            .first
//    }
//}
