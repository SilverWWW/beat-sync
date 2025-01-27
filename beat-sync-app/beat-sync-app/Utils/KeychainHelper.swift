//
//  KeychainHelper.swift
//  beat-sync-app
//
//  Created by Will Silver on 1/19/25.
//

import Foundation
import Security

class KeychainHelper {

    // save a key/value
    static func save(key: String, value: String) -> Void {
        let data = value.data(using: .utf8)!

        if read(key: key) != nil {
            // update the existing key
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            if status != errSecSuccess {
                print("Error updating keychain: \(status)")
            }
        } else {
            // add a new key
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecValueData as String: data
            ]
            let status = SecItemAdd(query as CFDictionary, nil)
            if status != errSecSuccess {
                print("Error saving to keychain: \(status)")
            }
        }
    }

    // read a key/value
    static func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    // delete a key/value
    static func delete(key: String) -> Void {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            print("Error deleting from keychain: \(status)")
        }
    }
}
