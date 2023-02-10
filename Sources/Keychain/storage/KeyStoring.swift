import Foundation

protocol KeyStoring {
    func set(_ value: Data, key: String)
    func get(_ key: String) -> Data?
}
