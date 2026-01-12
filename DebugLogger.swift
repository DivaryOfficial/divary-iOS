//
//  DebugLogger.swift
//  Divary
//
//  Created by AI Assistant on 1/12/26.
//

import Foundation

/// 디버그 빌드에서만 로그를 출력하는 헬퍼
struct DebugLogger {
    
    /// 일반 로그
    static func log(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        print("[\(fileName):\(line)] \(message)")
        #endif
    }
    
    /// 성공 로그 (✅)
    static func success(_ message: String) {
        #if DEBUG
        print("✅ \(message)")
        #endif
    }
    
    /// 경고 로그 (⚠️)
    static func warning(_ message: String) {
        #if DEBUG
        print("⚠️ \(message)")
        #endif
    }
    
    /// 에러 로그 (❌)
    static func error(_ message: String) {
        #if DEBUG
        print("❌ \(message)")
        #endif
    }
    
    /// 정보 로그 (🔵)
    static func info(_ message: String) {
        #if DEBUG
        print("🔵 \(message)")
        #endif
    }
    
    /// 네트워크 로그 (🌐)
    static func network(_ message: String) {
        #if DEBUG
        print("🌐 \(message)")
        #endif
    }
    
    /// 토큰 관련 로그 (🔑)
    static func token(_ message: String) {
        #if DEBUG
        print("🔑 \(message)")
        #endif
    }
    
    /// 구분선 출력
    static func separator(_ length: Int = 60, char: String = "=") {
        #if DEBUG
        print(String(repeating: char, count: length))
        #endif
    }
}
