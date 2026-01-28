import Foundation
import Security

/// Secure storage for sensitive data using iOS Keychain
/// The Keychain is hardware-encrypted and persists across app reinstalls
class KeychainService {
    static let shared = KeychainService()

    private let service = "com.gymbuddy.app"

    private init() {}

    // MARK: - Keys

    enum Key: String {
        case elevenLabsApiKey = "elevenlabs_api_key"
    }

    // MARK: - Public API

    /// Save a string securely to the Keychain
    func save(_ value: String, for key: Key) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        // Delete existing item first
        delete(key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecSuccess {
            print("KeychainService: Saved \(key.rawValue)")
            return true
        } else {
            print("KeychainService: Failed to save \(key.rawValue), status: \(status)")
            return false
        }
    }

    /// Retrieve a string from the Keychain
    func get(_ key: Key) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }

        return string
    }

    /// Delete an item from the Keychain
    @discardableResult
    func delete(_ key: Key) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    /// Check if a key exists in the Keychain
    func exists(_ key: Key) -> Bool {
        return get(key) != nil
    }
}
