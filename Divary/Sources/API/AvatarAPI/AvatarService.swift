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
        case .apiError(_, let message, _):
            return message
        }
    }
}

final class AvatarService {
    private let provider = MoyaProvider<AvatarAPI>()
    
    // 아바타 조회
    func getAvatar(completion: @escaping (Result<AvatarResponseDTO, Error>) -> Void) {
        provider.request(.getAvatar) { result in
            self.handleAvatarResponse(result, completion: completion)
        }
    }
    
    // 아바타 저장
    func saveAvatar(avatar: AvatarRequestDTO, completion: @escaping (Result<AvatarResponseDTO, Error>) -> Void) {
        provider.request(.saveAvatar(avatar: avatar)) { result in
            self.handleAvatarResponse(result, completion: completion)
        }
    }
    
    // 아바타 전용 Response Handler
    private func handleAvatarResponse(_ result: Result<Response, MoyaError>, completion: @escaping (Result<AvatarResponseDTO, Error>) -> Void) {
        switch result {
        case .success(let response):
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("📦 아바타 서버 응답: \(jsonString)")
            }
            
            do {
                // 먼저 에러 응답인지 확인 (status가 200이 아니거나 에러 코드인 경우)
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
                
                // 먼저 data 필드가 있는 구조로 시도
                do {
                    let successResponse = try JSONDecoder().decode(AvatarApiSuccessResponse<AvatarResponseDTO>.self, from: response.data)
                    
                    if successResponse.code == "SUCCESS" {
                        print("✅ data 필드가 있는 성공 응답 처리")
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
                    // data 필드가 없는 경우, 직접 AvatarResponseDTO로 디코딩 시도
                    print("🔄 data 필드 없는 응답으로 재시도")
                    do {
                        let avatarResponse = try JSONDecoder().decode(AvatarResponseDTO.self, from: response.data)
                        print("✅ 직접 아바타 응답 처리 성공")
                        completion(.success(avatarResponse))
                    } catch {
                        // 저장 성공 후 빈 응답인 경우 (status 200이지만 데이터 없음)
                        print("🔄 빈 응답으로 판단, 기본 아바타 생성")
                        print("  디코딩 오류: \(error)")
                        
                        // 200 OK이면 저장 성공으로 간주하고 기본 응답 생성
                        let emptyAvatar = AvatarResponseDTO(
                            name: nil,
                            tank: nil,
                            bodyColor: nil,
                            bubbleText: nil,
                            cheekColor: nil,
                            speechBubble: nil,
                            buddyPetInfo: nil,
                            mask: nil,
                            pin: nil,
                            regulator: nil,
                            theme: nil
                        )
                        print("✅ 저장 성공으로 처리 (빈 응답)")
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
