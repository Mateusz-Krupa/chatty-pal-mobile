import Foundation
import Security
import Observation

@MainActor
@Observable
final class AuthSession {
    private(set) var jwt: String

    private static let keychainService = "com.chattypal.ios"
    private static let keychainAccount = "auth.jwt"

    init() {
        jwt = KeychainStore.read(service: Self.keychainService, key: Self.keychainAccount)
            ?? Self.migrateLegacyUserDefaultsValue() ?? ""
    }

    var isAuthenticated: Bool { !jwt.isEmpty }

    func signIn(with token: String) {
        jwt = token
        KeychainStore.write(service: Self.keychainService, key: Self.keychainAccount, value: token)
    }

    func signOut() {
        jwt = ""
        KeychainStore.delete(service: Self.keychainService, key: Self.keychainAccount)
    }

    private static func migrateLegacyUserDefaultsValue() -> String? {
        guard let legacy = UserDefaults.standard.string(forKey: "jwt"), !legacy.isEmpty else {
            return nil
        }
        UserDefaults.standard.removeObject(forKey: "jwt")
        return legacy
    }
}

enum KeychainStore {
    static func read(service: String, key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func write(service: String, key: String, value: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        let updateAttributes: [String: Any] = [kSecValueData as String: data]
        let status = SecItemUpdate(query as CFDictionary, updateAttributes as CFDictionary)
        guard status == errSecItemNotFound else { return }
        var addQuery = query
        addQuery[kSecValueData as String] = data
        addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        SecItemAdd(addQuery as CFDictionary, nil)
    }

    static func delete(service: String, key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
