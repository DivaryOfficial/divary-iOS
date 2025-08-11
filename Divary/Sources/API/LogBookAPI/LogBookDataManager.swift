//
//  LogBookDataManager.swift - 새로 생성
//  Mock 데이터 매니저를 실제 API 서비스로 교체
//

import Foundation
import SwiftUI

@Observable
class LogBookDataManager {
    static let shared = LogBookDataManager()
    
    private let service = LogBookService()
    var logBookBases: [LogBookBase] = []
    
    private init() {}
    
    // MARK: - 연도별 로그 조회
    func loadLogs(for year: Int) async {
        do {
            let response = try await withCheckedThrowingContinuation { continuation in
                service.getLogList(year: year) { result in
                    continuation.resume(with: result)
                }
            }
            
            await MainActor.run {
                self.logBookBases = response.logs.map { dto in
                    LogBookBase(
                        id: String(dto.id),
                        date: self.parseDate(dto.date) ?? Date(),
                        title: dto.name,
                        iconType: IconType(rawValue: dto.iconType) ?? .clownfish,
                        logs: [],
                        saveStatus: .complete
                    )
                }
            }
        } catch {
            print("❌ 로그 로드 실패: \(error)")
            // 에러 시 빈 배열로 설정
            await MainActor.run {
                self.logBookBases = []
            }
        }
    }
    
    // MARK: - 새 로그 생성
    func createNewLog(date: Date, title: String, iconType: IconType) async -> String? {
        let dateString = formatDate(date)
        
        do {
            let response = try await withCheckedThrowingContinuation { continuation in
                service.createLog(iconType: iconType.rawValue, name: title, date: dateString) { result in
                    continuation.resume(with: result)
                }
            }
            
            let newLogBase = LogBookBase(
                id: String(response.id),
                date: date,
                title: response.name,
                iconType: iconType,
                logs: [],
                saveStatus: .complete
            )
            
            await MainActor.run {
                self.logBookBases.append(newLogBase)
            }
            
            return String(response.id)
        } catch {
            print("❌ 로그 생성 실패: \(error)")
            return nil
        }
    }
    
    // MARK: - 특정 날짜 로그 존재 확인
    func hasExistingLog(for date: Date) async -> Bool {
        let dateString = formatDate(date)
        
        do {
            let response = try await withCheckedThrowingContinuation { continuation in
                service.checkLogExists(date: dateString) { result in
                    continuation.resume(with: result)
                }
            }
            return response.exists
        } catch {
            print("❌ 로그 존재 확인 실패: \(error)")
            return false
        }
    }
    
    // MARK: - 기존 로그 찾기
    func findLogBase(for date: Date) -> LogBookBase? {
        let calendar = Calendar.current
        return logBookBases.first { logBase in
            calendar.isDate(logBase.date, inSameDayAs: date)
        }
    }
    
    // MARK: - 로그 삭제
    func deleteLog(id: String) async -> Bool {
        guard let logId = Int(id) else { return false }
        
        do {
            try await withCheckedThrowingContinuation { continuation in
                service.deleteLog(id: logId) { result in
                    continuation.resume(with: result)
                }
            }
            
            await MainActor.run {
                self.logBookBases.removeAll { $0.id == id }
            }
            return true
        } catch {
            print("❌ 로그 삭제 실패: \(error)")
            return false
        }
    }
    
    // MARK: - Helper Methods
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
