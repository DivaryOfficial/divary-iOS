//
//  KeyChainManager.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/10/25.
//

import SwiftUI
import Security

enum KeyChainKey {
    static let accessToken = "accessToken"
    static let refreshToken = "refreshToken"
}

final class KeyChainManager {
    static let shared = KeyChainManager()
    private init() {}

    // 저장
    func save(_ value: String, forKey key: String) {
        if let data = value.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecValueData as String: data
            ]
            SecItemDelete(query as CFDictionary) // 기존 값 제거
            SecItemAdd(query as CFDictionary, nil)
        }
    }

    // 불러오기
    func read(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    // 삭제
    func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    
    func readAccessToken() -> String? {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrAccount as String: "jwtToken",
//            kSecReturnData as String: true,
//            kSecMatchLimit as String: kSecMatchLimitOne
//        ]
//        var item: CFTypeRef?
//        if SecItemCopyMatching(query as CFDictionary, &item) == noErr {
//            if let data = item as? Data {
//                return String(data: data, encoding: .utf8)
//            }
//        }
//        return nil
        return read(forKey: KeyChainKey.accessToken)
    }
}
