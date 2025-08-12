//
//  Response.swift
//  Divary
//
//  Created by 김나영 on 8/6/25.
//

import Foundation

struct DefaultResponse<T: Codable>: Codable {
    let timestamp: String?
    let status: Int
    let code: String
    let message: String
    let path: String?
    let data: T?
}
