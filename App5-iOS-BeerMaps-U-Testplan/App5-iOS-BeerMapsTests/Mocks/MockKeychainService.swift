import Foundation
@testable import App5_iOS_BeerMaps

final class MockKeychainService: KeychainServiceProtocol {
    var storage: [String: String] = [:]
    var saveCallCount = 0
    var loadCallCount = 0
    var deleteCallCount = 0
    var shouldSaveFail = false

    func save(key: String, value: String) -> Bool {
        saveCallCount += 1
        if shouldSaveFail { return false }
        storage[key] = value
        return true
    }

    func load(key: String) -> String? {
        loadCallCount += 1
        return storage[key]
    }

    func delete(key: String) -> Bool {
        deleteCallCount += 1
        storage.removeValue(forKey: key)
        return true
    }
}
