//
//  AvatarService.swift
//  Divary
//
//  Created by 바견규 on 8/8/25.
//

import Foundation
import Moya

enum ServerError: LocalizedError {
    case apiError(code: String, message: String, status: Int)
    var errorDescription: String? {
        switch self {
        case .apiError(_, let message, _): return message
        }
    }
}

final class AvatarService {
    private let provider = MoyaProvider<AvatarAPI>()
    
    func getAvatar(completion: @escaping (Result<AvatarResponseDTO, Error>) -> Void) {
        provider.requestWithAutoRefresh(
            makeTarget: { .getAvatar }
        ) { result in
            self.handleAvatarResponse(result, completion: completion)
        }
    }
    
    func saveAvatar(avatar: AvatarRequestDTO, completion: @escaping (Result<AvatarResponseDTO, Error>) -> Void) {
        provider.requestWithAutoRefresh(
            makeTarget: { .saveAvatar(avatar: avatar) }
        ) { result in
            self.handleAvatarResponse(result, completion: completion)
        }
    }
    
    private func handleAvatarResponse(_ result: Result<Response, MoyaError>, completion: @escaping (Result<AvatarResponseDTO, Error>) -> Void) {
        switch result {
        case .success(let response):
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("📦 아바타 서버 응답: \(jsonString)")
            }
            do {
                if response.statusCode != 200 {
                    let errorResponse = try JSONDecoder().decode(AvatarApiErrorResponse.self, from: response.data)
                    let error = ServerError.apiError(
                        code: errorResponse.code,
                        message: errorResponse.message,
                        status: errorResponse.status
                    )
                    completion(.failure(error))
                    return
                }
                do {
                    let successResponse = try JSONDecoder().decode(AvatarApiSuccessResponse<AvatarResponseDTO>.self, from: response.data)
                    if successResponse.code == "SUCCESS" {
                        completion(.success(successResponse.data))
                    } else {
                        let error = ServerError.apiError(
                            code: successResponse.code,
                            message: successResponse.message,
                            status: successResponse.status
                        )
                        completion(.failure(error))
                    }
                } catch {
                    do {
                        let avatarResponse = try JSONDecoder().decode(AvatarResponseDTO.self, from: response.data)
                        completion(.success(avatarResponse))
                    } catch {
                        let emptyAvatar = AvatarResponseDTO(
                            name: nil, tank: nil, bodyColor: nil, bubbleText: nil,
                            cheekColor: nil, speechBubble: nil, buddyPetInfo: nil,
                            mask: nil, pin: nil, regulator: nil, theme: nil
                        )
                        completion(.success(emptyAvatar))
                    }
                }
            } catch {
                print("❌ 아바타 디코딩 실패: \(error)")
                completion(.failure(error))
            }
        case .failure(let error):
            print("❌ 네트워크 요청 실패: \(error)")
            completion(.failure(error))
        }
    }
}
