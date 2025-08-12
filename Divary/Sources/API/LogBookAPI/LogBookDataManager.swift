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
    
    // ✅ 중복 생성 방지를 위한 플래그들
    private var isCreatingLogBase = false
    private var creatingLogBaseForDate: String?
    
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
                    if let apiError = error as? LogBookAPIError, apiError.statusCode == 500 {
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
            // 빈 로그북 1개로 임시 로그베이스 생성
            let emptyLogBook = LogBook(
                id: "temp_\(logBaseInfoId)_0",
                logBookId: -1, // 임시 ID
                saveStatus: .temp,
                diveData: DiveLogData()
            )
            
            let tempLogBase = LogBookBase(
                id: cachedLogBase.id,
                logBaseInfoId: cachedLogBase.logBaseInfoId,
                date: cachedLogBase.date,
                title: cachedLogBase.title,
                iconType: cachedLogBase.iconType,
                accumulation: cachedLogBase.accumulation,
                logBooks: [emptyLogBook] // 1개만 생성
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
    
    // MARK: - ✅ 새 로그베이스 생성 (빈 로그북 1개만 생성) - 중복 방지 강화
    func createLogBase(iconType: IconType, name: String, date: Date, completion: @escaping (Result<String, Error>) -> Void) {
        
        let dateString = DateFormatter.apiDateFormatter.string(from: date)
        
        // ✅ 중복 생성 방지: 같은 날짜로 이미 생성 중인지 확인
        if isCreatingLogBase && creatingLogBaseForDate == dateString {
            print("⚠️ 같은 날짜(\(dateString))로 이미 로그베이스 생성 중이므로 요청 무시")
            let error = NSError(domain: "DuplicateCreation", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미 같은 날짜로 로그를 생성 중입니다."])
            completion(.failure(error))
            return
        }
        
        // ✅ 캐시에서 이미 존재하는지 확인
        if let existingLog = findLogBase(for: date) {
            print("⚠️ 이미 존재하는 로그베이스를 발견: \(existingLog.id)")
            completion(.success(existingLog.id))
            return
        }
        
        // 중복 생성 방지 플래그 설정
        isCreatingLogBase = true
        creatingLogBaseForDate = dateString
        
        print("🚀 데이터매니저의 로그베이스 생성 시작: \(name), 날짜: \(dateString)")
        
        service.createLogBase(iconType: iconType.rawValue, name: name, date: dateString) { [weak self] result in
            DispatchQueue.main.async {
                // 플래그 해제
                self?.isCreatingLogBase = false
                self?.creatingLogBaseForDate = nil
                
                switch result {
                case .success(let createResponse):
                    let logBaseInfoId = createResponse.logBaseInfoId
                    
                    print("✅ 로그베이스 생성 성공: logBaseInfoId=\(logBaseInfoId)")
                    
                    // ✅ 빈 로그북 1개만 생성
                    self?.createOneEmptyLogBook(
                        logBaseInfoId: logBaseInfoId,
                        date: date,
                        name: name,
                        iconType: iconType,
                        accumulation: createResponse.accumulation ?? 0
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
                                accumulation: createResponse.accumulation ?? 0,
                                logBooks: []
                            )
                            self?.logBookBases.append(newLogBase)
                            completion(.success(String(logBaseInfoId)))
                        }
                    }
                    
                case .failure(let error):
                    print("❌ 로그베이스 생성 실패: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    // ✅ 빈 로그북 1개만 생성하는 메서드
    private func createOneEmptyLogBook(
        logBaseInfoId: Int,
        date: Date,
        name: String,
        iconType: IconType,
        accumulation: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // 1번만 API 호출
        service.createEmptyLogBooks(logBaseInfoId: logBaseInfoId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("✅ 빈 로그북 1개 생성 성공: logBookId=\(response.logBookId)")
                    
                    // 빈 로그북 1개로 로그베이스 생성
                    let emptyLogBook = LogBook(
                        id: String(response.logBookId),
                        logBookId: response.logBookId,
                        saveStatus: .temp,
                        diveData: DiveLogData()
                    )
                    
                    let newLogBase = LogBookBase(
                        id: String(logBaseInfoId),
                        logBaseInfoId: logBaseInfoId,
                        date: date,
                        title: name,
                        iconType: iconType,
                        accumulation: accumulation,
                        logBooks: [emptyLogBook] // 1개만 포함
                    )
                    
                    self?.logBookBases.append(newLogBase)
                    completion(.success(()))
                    
                case .failure(let error):
                    print("❌ 빈 로그북 생성 실패: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - ✅ 기존 로그베이스에 새 로그북 추가 (슬라이드 시 사용)
    func addNewLogBook(logBaseInfoId: Int, completion: @escaping (Result<Int, Error>) -> Void) {
        // 현재 로그북 개수 확인
        if let logBase = logBookBases.first(where: { $0.logBaseInfoId == logBaseInfoId }) {
            if logBase.logBooks.count >= 3 {
                let error = NSError(domain: "MaxLogBookError", code: -1, userInfo: [NSLocalizedDescriptionKey: "최대 3개까지만 추가할 수 있습니다."])
                completion(.failure(error))
                return
            }
        }
        
        service.createEmptyLogBooks(logBaseInfoId: logBaseInfoId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    // 새 로그북을 기존 로그베이스에 추가
                    if let index = self?.logBookBases.firstIndex(where: { $0.logBaseInfoId == logBaseInfoId }) {
                        let newLogBook = LogBook(
                            id: String(response.logBookId),
                            logBookId: response.logBookId,
                            saveStatus: .temp,
                            diveData: DiveLogData()
                        )
                        self?.logBookBases[index].logBooks.append(newLogBook)
                    }
                    
                    completion(.success(response.logBookId))
                    print("✅ 새 로그북 추가 성공: logBookId=\(response.logBookId)")
                    
                case .failure(let error):
                    completion(.failure(error))
                    print("❌ 새 로그북 추가 실패: \(error)")
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
    
    // MARK: - ❌ 사용하지 않는 메서드 (기존 createLogBaseOnly는 더 이상 사용하지 않음)
    // createLogBase가 이미 빈 로그북 1개만 생성하므로 별도 메서드 불필요
}
