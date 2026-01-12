//
//  BaseService.swift
//  Divary
//
//  Created by 송재곤 on 9/17/25.
//


import Foundation
import Moya

class BaseService {
    /// 모든 API 응답을 일관되게 처리하고, 에러를 APIError enum으로 반환하는 함수
    func handleResponse<T: Codable>(_ result: Result<Response, MoyaError>, completion: @escaping (Result<T, APIError>) -> Void) {
        switch result {
        case .success(let response):
            // 요청 정보 출력
            DebugLogger.log("API Request Info:")
            DebugLogger.log("   URL: \(response.request?.url?.absoluteString ?? "N/A")")
            DebugLogger.log("   Method: \(response.request?.httpMethod ?? "N/A")")
            
            // 요청 헤더 출력
            if let headers = response.request?.allHTTPHeaderFields {
                DebugLogger.log("   Request Headers:")
                headers.forEach { key, value in
                    if key.lowercased().contains("authorization") || key.lowercased().contains("token") {
                        DebugLogger.log("      \(key): \(value.prefix(30))...")
                    } else {
                        DebugLogger.log("      \(key): \(value)")
                    }
                }
            }
            
            // 원본 응답 데이터 출력
            if let jsonString = String(data: response.data, encoding: .utf8) {
                DebugLogger.log("API Response [\(response.statusCode)]:")
                DebugLogger.log(jsonString)
            }
            
            do {
                // 프로젝트의 DefaultResponse<T> 모델로 디코딩
                let decodedResponse = try JSONDecoder().decode(DefaultResponse<T>.self, from: response.data)
                
                // HTTP 상태 코드나 내부 코드로 성공/실패 분기
                if (200...299).contains(decodedResponse.status) {
                    if let data = decodedResponse.data {
                        // 성공 시 실제 데이터(T) 전달
                        DebugLogger.success("API Success: status=\(decodedResponse.status), code=\(decodedResponse.code)")
                        completion(.success(data))
                    } else {
                        // 성공이지만 데이터가 없는 경우 .resultNil 에러 전달
                        DebugLogger.warning("API Warning: 응답 성공이지만 데이터가 nil")
                        completion(.failure(.resultNil))
                    }
                } else {
                    // 서버가 정의한 에러를 .responseState 케이스로 전달
                    DebugLogger.error("API Error: status=\(decodedResponse.status), code=\(decodedResponse.code), message=\(decodedResponse.message)")
                    completion(.failure(.responseState(
                        status: decodedResponse.status,
                        code: decodedResponse.code,
                        message: decodedResponse.message
                    )))
                }
            } catch {
                // JSON 디코딩 실패 시 .responseState 케이스로 에러 전달
                DebugLogger.error("Decoding Error: \(error.localizedDescription)")
                completion(.failure(.responseState(
                    status: response.statusCode,
                    code: "DECODING_ERROR",
                    message: "디코딩에 실패했습니다: \(error.localizedDescription)"
                )))
            }
        case .failure(let moyaError):
            // 네트워크 통신 자체에 실패한 경우 .moya 에러 전달
            DebugLogger.error("Network Error: \(moyaError.localizedDescription)")
            completion(.failure(.moya(error: moyaError)))
        }
    }
}
