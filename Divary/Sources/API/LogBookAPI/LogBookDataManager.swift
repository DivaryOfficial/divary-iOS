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
        service.getLogBaseDetail(logBaseInfoId: logBaseInfoId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let logBaseDetailDTOs):
                    if let logBase = logBaseDetailDTOs.toLogBookBase(logBaseInfoId: logBaseInfoId) {
                        // 캐시 업데이트
                        if let index = self?.logBookBases.firstIndex(where: { $0.logBaseInfoId == logBaseInfoId }) {
                            self?.logBookBases[index] = logBase
                        }
                        completion(.success(logBase))
                    } else {
                        let error = NSError(domain: "DataConversion", code: -1, userInfo: [NSLocalizedDescriptionKey: "로그베이스 변환 실패"])
                        completion(.failure(error))
                    }
                    
                case .failure(let error):
                    // 서버 에러인 경우 임시 로그베이스 생성하여 반환
                    if let apiError = error as? APIError, apiError.statusCode == 500 {
                        print("⚠️ 서버 에러로 인해 임시 로그베이스 생성: \(logBaseInfoId)")
                        self?.createTemporaryLogBase(logBaseInfoId: logBaseInfoId, completion: completion)
                    } else {
                        completion(.failure(error))
                        print("❌ 로그베이스 상세 조회 실패: \(error)")
                    }
                }
            }
        }
    }
    
    // 임시 로그베이스 생성 (서버 에러 시 대체용)
    private func createTemporaryLogBase(logBaseInfoId: Int, completion: @escaping (Result<LogBookBase, Error>) -> Void) {
        // 캐시에서 기본 정보를 찾아서 임시 로그베이스 생성
        if let cachedLogBase = logBookBases.first(where: { $0.logBaseInfoId == logBaseInfoId }) {
            // 빈 로그북 3개로 임시 로그베이스 생성
            let emptyLogBooks = Array(0..<3).map { index in
                LogBook(
                    id: "temp_\(logBaseInfoId)_\(index)",
                    logBookId: -1, // 임시 ID
                    saveStatus: .complete,
                    diveData: DiveLogData()
                )
            }
            
            let tempLogBase = LogBookBase(
                id: cachedLogBase.id,
                logBaseInfoId: cachedLogBase.logBaseInfoId,
                date: cachedLogBase.date,
                title: cachedLogBase.title,
                iconType: cachedLogBase.iconType,
                accumulation: cachedLogBase.accumulation,
                logBooks: emptyLogBooks
            )
            
            // 캐시 업데이트
            if let index = logBookBases.firstIndex(where: { $0.logBaseInfoId == logBaseInfoId }) {
                logBookBases[index] = tempLogBase
            }
            
            completion(.success(tempLogBase))
        } else {
            let error = NSError(domain: "TemporaryLogBase", code: -1, userInfo: [NSLocalizedDescriptionKey: "임시 로그베이스 생성 실패: 캐시에서 기본 정보를 찾을 수 없습니다."])
            completion(.failure(error))
        }
    }
    
    // MARK: - 새 로그베이스 생성 (수정됨)
    func createLogBase(iconType: IconType, name: String, date: Date, completion: @escaping (Result<String, Error>) -> Void) {
        let dateString = DateFormatter.apiDateFormatter.string(from: date)
        
        service.createLogBase(iconType: iconType.rawValue, name: name, date: dateString) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let createResponse):
                    let logBaseInfoId = createResponse.logBaseInfoId
                    
                    // ✅ 빈 로그북 3개 생성 (3번 API 호출)
                    self?.createThreeEmptyLogBooks(
                        logBaseInfoId: logBaseInfoId,
                        date: date,
                        name: name,
                        iconType: iconType,
                        accumulation: createResponse.accumulation
                    ) { emptyResult in
                        switch emptyResult {
                        case .success:
                            completion(.success(String(logBaseInfoId)))
                            
                        case .failure(let error):
                            // 빈 로그북 생성 실패해도 로그베이스는 생성되었으므로 캐시에 추가
                            print("⚠️ 빈 로그북 생성 실패했지만 로그베이스는 생성됨: \(error)")
                            let newLogBase = LogBookBase(
                                id: String(logBaseInfoId),
                                logBaseInfoId: logBaseInfoId,
                                date: date,
                                title: name,
                                iconType: iconType,
                                accumulation: createResponse.accumulation,
                                logBooks: []
                            )
                            self?.logBookBases.append(newLogBase)
                            completion(.success(String(logBaseInfoId)))
                        }
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
                    print("❌ 로그베이스 생성 실패: \(error)")
                }
            }
        }
    }
    
    // ✅ 빈 로그북 3개 생성 (3번 API 호출)
    private func createThreeEmptyLogBooks(
        logBaseInfoId: Int,
        date: Date,
        name: String,
        iconType: IconType,
        accumulation: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        var completedCount = 0
        var hasError = false
        var firstError: Error?
        
        // 3번 연속 API 호출
        for i in 1...3 {
            service.createEmptyLogBooks(logBaseInfoId: logBaseInfoId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        completedCount += 1
                        print("✅ 빈 로그북 \(i)번째 생성 성공: logBookId=\(response.logBookId)")
                        
                        // 3개 모두 완료되면 캐시에 로그베이스 추가
                        if completedCount == 3 && !hasError {
                            let newLogBase = LogBookBase(
                                id: String(logBaseInfoId),
                                logBaseInfoId: logBaseInfoId,
                                date: date,
                                title: name,
                                iconType: iconType,
                                accumulation: accumulation,
                                logBooks: [] // 빈 로그북들은 상세 조회에서 가져옴
                            )
                            self.logBookBases.append(newLogBase)
                            completion(.success(()))
                        }
                        
                    case .failure(let error):
                        if !hasError {
                            hasError = true
                            firstError = error
                            print("❌ 빈 로그북 \(i)번째 생성 실패: \(error)")
                            completion(.failure(firstError!))
                        }
                    }
                }
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
    
    // 오프라인 로그베이스 추가
    func addOfflineLogBase(_ logBase: LogBookBase) {
        logBookBases.append(logBase)
        print("📱 오프라인 로그베이스 캐시에 추가: \(logBase.id)")
    }
    
    // 오프라인 로그베이스들 동기화 (서버 복구 시 호출)
    func syncOfflineLogBases() {
        let offlineLogBases = logBookBases.filter { $0.logBaseInfoId == -1 }
        
        for offlineLogBase in offlineLogBases {
            // 서버에 재시도하여 생성
            createLogBase(
                iconType: offlineLogBase.iconType,
                name: offlineLogBase.title,
                date: offlineLogBase.date
            ) { [weak self] result in
                switch result {
                case .success(let newLogBaseId):
                    // 성공하면 오프라인 로그 제거하고 새 로그로 교체
                    DispatchQueue.main.async {
                        self?.logBookBases.removeAll { $0.id == offlineLogBase.id }
                        print("✅ 오프라인 로그 동기화 완료: \(offlineLogBase.id) -> \(newLogBaseId)")
                    }
                case .failure(let error):
                    print("❌ 오프라인 로그 동기화 실패: \(error)")
                }
            }
        }
    }
}
