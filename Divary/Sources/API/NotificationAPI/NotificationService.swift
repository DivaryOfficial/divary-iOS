//
//  NotificationService.swift
//  Divary
//
//  Created by 바견규 on 8/8/25.
//


import Foundation
import Moya

final class NotificationService {
    private let provider = MoyaProvider<NotificationAPI>()

    func getNotifications(completion: @escaping (Result<NotificationListResponseDTO, Error>) -> Void) {
        provider.requestWithAutoRefresh(
            makeTarget: { .getNotifications }
        ) { result in
            self.handleResponse(result, completion: completion)
        }
    }
    
    func markAsRead(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.requestWithAutoRefresh(
            makeTarget: { .markAsRead(id: id) }
        ) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func handleResponse<T: Decodable>(_ result: Result<Response, MoyaError>, completion: @escaping (Result<T, Error>) -> Void) {
        switch result {
        case .success(let response):
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("📦 알림 서버 응답: \(jsonString)")
            }
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: response.data)
                completion(.success(decodedData))
            } catch {
                print("❌ 알림 디코딩 실패: \(error)")
                completion(.failure(error))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
