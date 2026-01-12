//
//  LogBookService.swift
//  Divary
//
//  Created by 바견규 on 8/8/25.
//

import Foundation
import Moya

final class LogBookService {
    static let shared = LogBookService()
    private let provider = MoyaProvider<LogBookAPI>()
    
    private init() {}
    
    // 로그 리스트 조회 (연도별)
    func getLogList(year: Int, saveStatus: String? = nil, completion: @escaping (Result<[LogListResponseDTO], Error>) -> Void) {
        provider.requestWithAutoRefresh(
            makeTarget: { .getLogList(year: year, saveStatus: saveStatus) }
        ) { result in
            self.handleWrappedResponse(result, completion: completion)
        }
    }
    
    // 전체 로그 리스트 조회
    func getAllLogs(completion: @escaping (Result<[LogListResponseDTO], Error>) -> Void) {
        provider.requestWithAutoRefresh(
            makeTarget: { .getAllLogs }
        ) { result in
            self.handleWrappedResponse(result, completion: completion)
        }
    }
    
    // 로그베이스 상세 조회 (로그북들 포함)
    func getLogBaseDetail(logBaseInfoId: Int, completion: @escaping (Result<[LogBaseDetailDTO], Error>) -> Void) {
        provider.requestWithAutoRefresh(
            makeTarget: { .getLogBaseDetail(logBaseInfoId: logBaseInfoId) }
        ) { result in
            self.handleWrappedResponse(result, completion: completion)
        }
    }
    
    // 초기 로그베이스 생성
    func createLogBase(iconType: String, name: String, date: String, completion: @escaping (Result<LogCreateResponseDTO, Error>) -> Void) {
        provider.requestWithAutoRefresh(
            makeTarget: { .createLogBase(iconType: iconType, name: name, date: date) }
        ) { result in
            self.handleWrappedResponse(result, completion: completion)
        }
    }
    
    // 빈 로그북 3개 생성
    func createEmptyLogBooks(logBaseInfoId: Int, completion: @escaping (Result<EmptyLogCreateResponseDTO, Error>) -> Void) {
        provider.requestWithAutoRefresh(
            makeTarget: { .createEmptyLogBooks(logBaseInfoId: logBaseInfoId) }
        ) { result in
            self.handleWrappedResponse(result, completion: completion)
        }
    }
    
    // 개별 로그북 수정
    func updateLogBook(logBookId: Int, logData: LogUpdateRequestDTO, completion: @escaping (Result<EmptyLogCreateResponseDTO, Error>) -> Void) {
        provider.requestWithAutoRefresh(
            makeTarget: { .updateLogBook(logBookId: logBookId, logData: logData) }
        ) { result in
            self.handleWrappedResponse(result, completion: completion)
        }
    }
    
    // 로그베이스 제목 수정
    func updateLogBaseTitle(logBaseInfoId: Int, name: String, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.requestWithAutoRefresh(
            makeTarget: { .updateLogBaseTitle(logBaseInfoId: logBaseInfoId, name: name) }
        ) { result in
            switch result {
            case .success(let response):
                if let jsonString = String(data: response.data, encoding: .utf8) {
                    DebugLogger.log("로그베이스 제목 수정 응답: \(jsonString)")
                }
                
                if response.statusCode >= 400 {
                    do {
                        let errorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: response.data)
                        let error = LogBookAPIError(
                            code: errorResponse.code,
                            message: errorResponse.message,
                            statusCode: response.statusCode
                        )
                        completion(.failure(error))
                    } catch {
                        let fallbackError = LogBookAPIError(
                            code: "UNKNOWN_ERROR",
                            message: "제목 수정 중 오류가 발생했습니다. (Status: \(response.statusCode))",
                            statusCode: response.statusCode
                        )
                        completion(.failure(fallbackError))
                    }
                } else {
                    completion(.success(()))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 로그베이스 삭제
    func deleteLogBase(logBaseInfoId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.requestWithAutoRefresh(
            makeTarget: { .deleteLogBase(logBaseInfoId: logBaseInfoId) }
        ) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 특정 날짜 로그 존재 여부
    func checkLogExists(date: String, completion: @escaping (Result<LogExistsResponseDTO, Error>) -> Void) {
        provider.requestWithAutoRefresh(
            makeTarget: { .checkLogExists(date: date) }
        ) { result in
            self.handleWrappedResponse(result, completion: completion)
        }
    }
    
    // 로그베이스 날짜 수정
    func updateLogBaseDate(logBaseInfoId: Int, date: String, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.requestWithAutoRefresh(
            makeTarget: { .updateLogBaseDate(logBaseInfoId: logBaseInfoId, date: date) }
        ) { result in
            switch result {
            case .success(let response):
                if let jsonString = String(data: response.data, encoding: .utf8) {
                    DebugLogger.log("로그베이스 날짜 수정 응답: \(jsonString)")
                }
                
                if response.statusCode >= 400 {
                    do {
                        let errorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: response.data)
                        let error = LogBookAPIError(
                            code: errorResponse.code,
                            message: errorResponse.message,
                            statusCode: response.statusCode
                        )
                        completion(.failure(error))
                    } catch {
                        let fallbackError = LogBookAPIError(
                            code: "UNKNOWN_ERROR",
                            message: "날짜 수정 중 오류가 발생했습니다. (Status: \(response.statusCode))",
                            statusCode: response.statusCode
                        )
                        completion(.failure(fallbackError))
                    }
                } else {
                    completion(.success(()))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 래핑된 응답 처리 (에러 처리 개선)
    private func handleWrappedResponse<T: Codable>(_ result: Result<Response, MoyaError>, completion: @escaping (Result<T, Error>) -> Void) {
        switch result {
        case .success(let response):
            if let jsonString = String(data: response.data, encoding: .utf8) {
                DebugLogger.log("로그북 서버 응답: \(jsonString)")
            }
            
            // 상태코드 체크
            if response.statusCode >= 400 {
                // 에러 응답 처리
                do {
                    let errorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: response.data)
                    let error = LogBookAPIError(
                        code: errorResponse.code,
                        message: errorResponse.message,
                        statusCode: response.statusCode
                    )
                    completion(.failure(error))
                } catch {
                    // 에러 응답 파싱도 실패
                    let fallbackError = LogBookAPIError(
                        code: "UNKNOWN_ERROR",
                        message: "서버 오류가 발생했습니다. (Status: \(response.statusCode))",
                        statusCode: response.statusCode
                    )
                    completion(.failure(fallbackError))
                }
                return
            }
            
            // 성공 응답 처리
            do {
                let wrappedResponse = try JSONDecoder().decode(APIResponse<T>.self, from: response.data)
                completion(.success(wrappedResponse.data))
            } catch {
                DebugLogger.error("로그북 디코딩 실패: \(error)")
                completion(.failure(error))
            }
            
        case .failure(let error):
            completion(.failure(error))
        }
    }
}

// MARK: - 에러 모델
struct APIErrorResponse: Codable {
    let timestamp: String
    let status: Int
    let code: String
    let message: String
    let path: String?
}

struct LogBookAPIError: Error, LocalizedError {
    let code: String
    let message: String
    let statusCode: Int
    var errorDescription: String? { message }
}
