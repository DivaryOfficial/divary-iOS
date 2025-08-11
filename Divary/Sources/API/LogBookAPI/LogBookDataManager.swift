//
//  LogBookDataManager.swift
//  Divary
//
//  Created by 개발자 on 8/11/25.
//

import Foundation

@Observable
class LogBookDataManager {
    static let shared = LogBookDataManager()
    
    private let service = LogBookService.shared
    private(set) var logBookBases: [LogBookBase] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    
    private init() {}
    
    // MARK: - 연도별 로그 리스트 조회
    func fetchLogList(for year: Int, completion: @escaping (Result<[LogBookBase], Error>) -> Void) {
        isLoading = true
        errorMessage = nil
        
        service.getLogList(year: year) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let logListDTOs):
                    let logBases = logListDTOs.map { $0.toLogBookBase() }
                    self?.logBookBases = logBases
                    completion(.success(logBases))
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    print("❌ 로그 리스트 조회 실패: \(error)")
                }
            }
        }
    }
    
    // MARK: - 특정 연도의 로그베이스들 필터링 (로컬 캐시 사용)
    func getLogBases(for year: Int) -> [LogBookBase] {
        return logBookBases.filter { logBase in
            Calendar.current.component(.year, from: logBase.date) == year
        }
    }
    
    // MARK: - 로그베이스 상세 조회
    func fetchLogBaseDetail(logBaseInfoId: Int, completion: @escaping (Result<LogBookBase, Error>) -> Void) {
        service.getLogBaseDetail(logBaseInfoId: logBaseInfoId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let logBaseDetailDTOs):
                    if let logBase = logBaseDetailDTOs.toLogBookBase(logBaseInfoId: logBaseInfoId) {
    //if let logBase = logBaseDetailDTOs.toLogBookBase(logBaseInfoId: logBaseInfoId) { 이거였는데 오류 남
                        // 캐시 업데이트
                        if let index = self.logBookBases.firstIndex(where: { $0.logBaseInfoId == logBaseInfoId }) {
                            self.logBookBases[index] = logBase
                        }
                        completion(.success(logBase))
                    } else {
                        let error = NSError(domain: "DataConversion", code: -1, userInfo: [NSLocalizedDescriptionKey: "로그베이스 변환 실패"])
                        completion(.failure(error))
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
                    print("❌ 로그베이스 상세 조회 실패: \(error)")
                }
            }
        }
    }
    
    // MARK: - 새 로그베이스 생성
    func createLogBase(iconType: IconType, name: String, date: Date, completion: @escaping (Result<String, Error>) -> Void) {
        let dateString = DateFormatter.apiDateFormatter.string(from: date)
        
        service.createLogBase(iconType: iconType.rawValue, name: name, date: dateString) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let createResponse):
                    let logBaseInfoId = createResponse.logBaseInfoId
                    
                    // 빈 로그북 3개 생성
                    self?.createEmptyLogBooks(logBaseInfoId: logBaseInfoId) { emptyResult in
                        switch emptyResult {
                        case .success:
                            // 캐시에 새 로그베이스 추가
                            let newLogBase = LogBookBase(
                                id: String(logBaseInfoId),
                                logBaseInfoId: logBaseInfoId,
                                date: date,
                                title: name,
                                iconType: iconType,
                                accumulation: createResponse.accumulation,
                                logBooks: [] // 빈 로그북들은 나중에 상세 조회로 가져옴
                            )
                            self?.logBookBases.append(newLogBase)
                            completion(.success(String(logBaseInfoId)))
                            
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
                    print("❌ 로그베이스 생성 실패: \(error)")
                }
            }
        }
    }
    
    // MARK: - 빈 로그북 생성 (내부 메서드)
    private func createEmptyLogBooks(logBaseInfoId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        service.createEmptyLogBooks(logBaseInfoId: logBaseInfoId) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
                print("❌ 빈 로그북 생성 실패: \(error)")
            }
        }
    }
    
    // MARK: - 로그베이스 삭제
    func deleteLogBase(logBaseInfoId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        service.deleteLogBase(logBaseInfoId: logBaseInfoId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // 캐시에서 제거
                    self?.logBookBases.removeAll { $0.logBaseInfoId == logBaseInfoId }
                    completion(.success(()))
                    
                case .failure(let error):
                    completion(.failure(error))
                    print("❌ 로그베이스 삭제 실패: \(error)")
                }
            }
        }
    }
    
    // MARK: - 날짜별 로그 존재 확인
    func checkLogExists(for date: Date, completion: @escaping (Result<Bool, Error>) -> Void) {
        let dateString = DateFormatter.apiDateFormatter.string(from: date)
        
        service.checkLogExists(date: dateString) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let existsResponse):
                    completion(.success(existsResponse.exists))
                    
                case .failure(let error):
                    completion(.failure(error))
                    print("❌ 로그 존재 확인 실패: \(error)")
                }
            }
        }
    }
    
    // MARK: - 기존 로그 찾기 (MockDataManager 호환성)
    func findLogBase(for date: Date) -> LogBookBase? {
        return logBookBases.first { logBase in
            Calendar.current.isDate(logBase.date, inSameDayAs: date)
        }
    }
    
    // MARK: - 기존 로그 존재 여부 (MockDataManager 호환성)
    func hasExistingLog(for date: Date) -> Bool {
        return findLogBase(for: date) != nil
    }
    
    // MARK: - 캐시 새로고침
    func refreshCache(for year: Int) {
        fetchLogList(for: year) { _ in
            // 완료 처리는 호출하는 곳에서 담당
        }
    }
}
