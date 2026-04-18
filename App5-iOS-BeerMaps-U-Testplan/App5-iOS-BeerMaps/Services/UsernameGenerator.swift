import Foundation

enum KeychainKeys {
    static let username = "com.beermaps.username"
}

enum UsernameGenerator {
    private static let prefixes = [
        "Hopfen", "Blitz", "Nacht", "Mond", "Sturm", "Feuer", "Donner",
        "Gletscher", "Nebel", "Sonne", "Regen", "Wind", "Fluss", "Berg",
        "Wald", "Stern", "Schaum", "Malz", "Pils", "Lager", "Bock",
        "Weizen", "Dunkel", "Hell", "Stark", "Bitter", "Suess", "Herb"
    ]

    static func generateUsername() -> String {
        let prefix = prefixes.randomElement() ?? "Hopfen"
        return "\(prefix)kohol"
    }

    static func isValid(_ name: String?) -> Bool {
        guard let name = name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        return true
    }

    @discardableResult
    static func validUsername(from stored: String?, keychainService: KeychainServiceProtocol) -> String {
        if isValid(stored) {
            return stored!
        }
        let newName = generateUsername()
        _ = keychainService.save(key: KeychainKeys.username, value: newName)
        return newName
    }
}
