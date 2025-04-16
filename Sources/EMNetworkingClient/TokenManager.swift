//
//  TokenManager.swift
//  EMNetworking
//
//  Created by Mickael Belhassen on 15/04/2025.
//

import Foundation
import Security
import EMNetworking

final class KeychainTokenManager: TokenManaging {
    private let keychainQueue = DispatchQueue(label: "com.app.keychain")
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    private let expirationKey = "tokenExpiration"
    
    var token: String {
        ""
    }
    
    func refreshToken() async throws -> String {

        return "newToken"
    }
    
    var isTokenValid: Bool {
        true
    }
    
    // MARK: - Keychain helpers
    
    private func saveToKeychain(value: String, forKey key: String) throws {
        let data = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw TokenError.refreshFailed
        }
    }
    
    private func getKeychainValue(forKey key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess,
              let data = dataTypeRef as? Data,
              let value = String(data: data, encoding: .utf8) else {
            throw TokenError.invalidToken
        }
        
        return value
    }
    

    public enum TokenError: Error {
        case invalidToken
        case refreshFailed
        case tokenExpired
    }
}
