//
//  TokenManageRegistry.swift
//  Divary
//
//  Created by 바견규 on 10/7/25.
//

import Foundation

final class TokenManagerRegistry {
    static let shared = TokenManagerRegistry()
    private init() {}
    var manager: TokenManager?
}
