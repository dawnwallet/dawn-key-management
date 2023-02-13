import Foundation

public protocol WriterDirectory {
    func write<T: Codable>(_ account: T, at file: String) throws
    func delete(at file: String) throws
    func deleteAll() throws
    func retrieve<T: Codable>(objectType: T.Type) throws -> [T?]
}

public struct WalletWriterDirectory: WriterDirectory {

    enum Error: Swift.Error {
        case decodingError
    }

    private let fileSubfolder: String
    private let fileManager: FileManager

    public init(fileSubfolder: String) {
        self.fileSubfolder = fileSubfolder
        self.fileManager = FileManager.default
    }

    private var directoryPathSubfolder: String {
        NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }

    private var destination: URL {
        fileManager.containerURL(forSecurityApplicationGroupIdentifier: "")!
            .appendingPathComponent(fileSubfolder)
    }

    /// Search out any object of selected type stored on disk
    /// - Parameter objectType: Type of the object, must be codable
    /// - Returns: All objects found on disk
    public func retrieve<T: Codable>(objectType: T.Type) throws -> [T?] {
        try fileManager.createDirectory(at: destination, withIntermediateDirectories: true)
        let accountsUrl = try fileManager.contentsOfDirectory(
            at: destination,
            includingPropertiesForKeys: [],
            options: .skipsHiddenFiles
        )
        var accounts: [T?] = []
        do {
            for url in accountsUrl {
                let data = try Data(contentsOf: url)
                let account = try? JSONDecoder().decode(objectType, from: data)
                accounts.append(account)
            }
        } catch {
            throw Error.decodingError
        }
        return accounts
    }


    /// Write an object on disk
    /// - Parameters:
    ///   - object: Codable object to be stored
    ///   - file: File name where the object should be stored at
    public func write<T: Codable>(_ object: T, at file: String) throws {
        try fileManager.createDirectory(at: destination, withIntermediateDirectories: true)
        let json = try JSONEncoder().encode(object)
        try? json.write(to: folderUrl(file), options: [.atomic])
    }


    /// Delete object from file manager
    /// - Parameter file: File name to delete
    public func delete(at file: String) throws {
        try fileManager.removeItem(at: folderUrl(file))
    }

    /// Delete all objects stored on disk
    public func deleteAll() throws {
        let files = try fileManager.contentsOfDirectory(
            at: destination, includingPropertiesForKeys: nil)
        for file in files {
            try fileManager.removeItem(at: file)
        }
    }
}

extension WalletWriterDirectory {
    private func folderUrl(_ file: String) -> URL {
        destination.appendingPathComponent(file)
    }
}
