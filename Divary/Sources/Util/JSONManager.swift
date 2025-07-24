//
//  JSONManager.swift
//  Divary
//
//  Created by 김나영 on 7/24/25.
//

import Foundation

class JSONManager {
    
    public static let shared = JSONManager()
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        
    }
    
    func encode<T: Codable>(codable: T) -> Data? {
        do {
            return try encoder.encode(codable)
        } catch {
            NSLog(error.localizedDescription)
        }
        return nil
    }
    
    func decode<T: Codable>(data: Data, type: T.Type) -> T? {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            NSLog(error.localizedDescription)
        }
        return nil
    }
}
