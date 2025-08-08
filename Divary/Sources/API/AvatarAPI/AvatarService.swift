//
//  AvatarService.swift
//  Divary
//
//  Created by 바견규 on 8/8/25.
//

import Foundation
import Moya

final class AvatarService {
    private let provider = MoyaProvider<AvatarAPI>()

    
    // 아바타 조회
    func getAvatar(completion: @escaping (Result<AvatarResponseDTO, Error>) -> Void) {
        provider.request(.getAvatar) { result in
            self.handleResponse(result, completion: completion)
        }
    }
    
    // 아바타 저장
    func saveAvatar(avatar: AvatarRequestDTO, completion: @escaping (Result<AvatarResponseDTO, Error>) -> Void) {
        provider.request(.saveAvatar(avatar: avatar)) { result in
            self.handleResponse(result, completion: completion)
        }
    }
    
    // Generic Response Handler
    private func handleResponse<T: Decodable>(_ result: Result<Response, MoyaError>, completion: @escaping (Result<T, Error>) -> Void) {
        switch result {
        case .success(let response):
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("📦 아바타 서버 응답: \(jsonString)")
            }
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: response.data)
                completion(.success(decodedData))
            } catch {
                print("❌ 아바타 디코딩 실패: \(error)")
                completion(.failure(error))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
