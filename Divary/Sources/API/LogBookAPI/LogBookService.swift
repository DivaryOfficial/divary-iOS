//
//  LogBookService.swift
//  Divary
//
//  Created by 바견규 on 8/8/25.
//

import Foundation
import Moya

final class LogBookService {
    private let provider = MoyaProvider<LogBookAPI>()
    
    // 로그 리스트 조회
    func getLogList(year: Int, completion: @escaping (Result<LogListResponseDTO, Error>) -> Void) {
        provider.request(.getLogList(year: year)) { result in
            self.handleResponse(result, completion: completion)
        }
    }
    
    // 로그 상세 조회
    func getLogDetail(id: Int, completion: @escaping (Result<LogDetailResponseDTO, Error>) -> Void) {
        provider.request(.getLogDetail(id: id)) { result in
            self.handleResponse(result, completion: completion)
        }
    }
    
    // 초기 로그 생성
    func createLog(iconType: String, name: String, date: String, completion: @escaping (Result<LogItemDTO, Error>) -> Void) {
        provider.request(.createLog(iconType: iconType, name: name, date: date)) { result in
            self.handleResponse(result, completion: completion)
        }
    }
    
    // 로그북 전체 수정
    func updateLog(id: Int, logData: LogUpdateRequestDTO, completion: @escaping (Result<LogDetailResponseDTO, Error>) -> Void) {
        provider.request(.updateLog(id: id, logData: logData)) { result in
            self.handleResponse(result, completion: completion)
        }
    }
    
    // 빈 세부 로그북 페이지 생성
    func createEmptyLog(id: Int, completion: @escaping (Result<LogDetailResponseDTO, Error>) -> Void) {
        provider.request(.createEmptyLog(id: id)) { result in
            self.handleResponse(result, completion: completion)
        }
    }
    
    // 로그북 삭제
    func deleteLog(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.deleteLog(id: id)) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 로그북 이름 변경
    func updateLogName(id: Int, name: String, completion: @escaping (Result<LogItemDTO, Error>) -> Void) {
        provider.request(.updateLogName(id: id, name: name)) { result in
            self.handleResponse(result, completion: completion)
        }
    }
    
    // 특정 날짜 로그북 존재 여부
    func checkLogExists(date: String, completion: @escaping (Result<LogExistsResponseDTO, Error>) -> Void) {
        provider.request(.checkLogExists(date: date)) { result in
            self.handleResponse(result, completion: completion)
        }
    }
    
    // Generic Response Handler
    private func handleResponse<T: Decodable>(_ result: Result<Response, MoyaError>, completion: @escaping (Result<T, Error>) -> Void) {
        switch result {
        case .success(let response):
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("📦 로그북 서버 응답: \(jsonString)")
            }
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: response.data)
                completion(.success(decodedData))
            } catch {
                print("❌ 로그북 디코딩 실패: \(error)")
                completion(.failure(error))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
