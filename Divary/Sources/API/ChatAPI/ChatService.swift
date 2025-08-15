import Foundation
import Moya

final class ChatService {
    private let provider = MoyaProvider<ChatAPI>()
    
    // 메시지 전송 - imageData로 바이너리 데이터 직접 전송
    func sendMessage(chatRoomId: Int?, message: String, imageData: Data?, completion: @escaping (Result<SendMessageResponseDTO, Error>) -> Void) {
        provider.request(.sendMessage(chatRoomId: chatRoomId, message: message, imageData: imageData)) { result in
            self.handleSendMessageResponse(result, completion: completion)
        }
    }
    
    // 채팅방 목록 조회
    func getChatRooms(completion: @escaping (Result<ChatRoomListResponseDTO, Error>) -> Void) {
        provider.request(.getChatRooms) { result in
            self.handleChatRoomsResponse(result, completion: completion)
        }
    }
    
    // 채팅방 상세 조회
    func getChatRoomDetail(chatRoomId: Int, completion: @escaping (Result<ChatRoomDetailResponseDTO, Error>) -> Void) {
        provider.request(.getChatRoomDetail(chatRoomId: chatRoomId)) { result in
            self.handleChatRoomDetailResponse(result, completion: completion)
        }
    }
    
    // 채팅방 삭제
    func deleteChatRoom(chatRoomId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.deleteChatRoom(chatRoomId: chatRoomId)) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 채팅방 제목 변경
    func updateChatRoomTitle(chatRoomId: Int, title: String, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.updateChatRoomTitle(chatRoomId: chatRoomId, title: title)) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 메시지 전송 응답 처리
    private func handleSendMessageResponse(_ result: Result<Response, MoyaError>, completion: @escaping (Result<SendMessageResponseDTO, Error>) -> Void) {
        switch result {
        case .success(let response):
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("📦 챗봇 서버 응답: \(jsonString)")
            }
            
            // 상태 코드 확인
            if response.statusCode >= 400 {
                // 에러 응답 처리
                do {
                    let errorResponse = try JSONDecoder().decode(ChatErrorResponseDTO.self, from: response.data)
                    let error = NSError(domain: "ChatAPI", code: response.statusCode, userInfo: [
                        NSLocalizedDescriptionKey: errorResponse.message
                    ])
                    completion(.failure(error))
                } catch {
                    let error = NSError(domain: "ChatAPI", code: response.statusCode, userInfo: [
                        NSLocalizedDescriptionKey: "서버 오류가 발생했습니다."
                    ])
                    completion(.failure(error))
                }
                return
            }
            
            do {
                let baseResponse = try JSONDecoder().decode(ChatBaseResponseDTO<SendMessageResponseDTO>.self, from: response.data)
                completion(.success(baseResponse.data))
            } catch {
                print("❌ 챗봇 디코딩 실패: \(error)")
                completion(.failure(error))
            }
        case .failure(let error):
            print("❌ 챗봇 네트워크 에러: \(error)")
            completion(.failure(error))
        }
    }
    
    // 채팅방 목록 응답 처리
    private func handleChatRoomsResponse(_ result: Result<Response, MoyaError>, completion: @escaping (Result<ChatRoomListResponseDTO, Error>) -> Void) {
        switch result {
        case .success(let response):
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("📦 챗봇 서버 응답: \(jsonString)")
            }
            
            // 상태 코드 확인
            if response.statusCode >= 400 {
                // 에러 응답 처리
                do {
                    let errorResponse = try JSONDecoder().decode(ChatErrorResponseDTO.self, from: response.data)
                    let error = NSError(domain: "ChatAPI", code: response.statusCode, userInfo: [
                        NSLocalizedDescriptionKey: errorResponse.message
                    ])
                    completion(.failure(error))
                } catch {
                    let error = NSError(domain: "ChatAPI", code: response.statusCode, userInfo: [
                        NSLocalizedDescriptionKey: "서버 오류가 발생했습니다."
                    ])
                    completion(.failure(error))
                }
                return
            }
            
            do {
                let baseResponse = try JSONDecoder().decode(ChatBaseResponseDTO<ChatRoomListResponseDTO>.self, from: response.data)
                completion(.success(baseResponse.data))
            } catch {
                print("❌ 챗봇 디코딩 실패: \(error)")
                completion(.failure(error))
            }
        case .failure(let error):
            print("❌ 챗봇 네트워크 에러: \(error)")
            completion(.failure(error))
        }
    }
    
    // 채팅방 상세 응답 처리
    private func handleChatRoomDetailResponse(_ result: Result<Response, MoyaError>, completion: @escaping (Result<ChatRoomDetailResponseDTO, Error>) -> Void) {
        switch result {
        case .success(let response):
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("📦 챗봇 서버 응답: \(jsonString)")
            }
            
            // 상태 코드 확인
            if response.statusCode >= 400 {
                // 에러 응답 처리
                do {
                    let errorResponse = try JSONDecoder().decode(ChatErrorResponseDTO.self, from: response.data)
                    let error = NSError(domain: "ChatAPI", code: response.statusCode, userInfo: [
                        NSLocalizedDescriptionKey: errorResponse.message
                    ])
                    completion(.failure(error))
                } catch {
                    let error = NSError(domain: "ChatAPI", code: response.statusCode, userInfo: [
                        NSLocalizedDescriptionKey: "서버 오류가 발생했습니다."
                    ])
                    completion(.failure(error))
                }
                return
            }
            
            do {
                let baseResponse = try JSONDecoder().decode(ChatBaseResponseDTO<ChatRoomDetailResponseDTO>.self, from: response.data)
                completion(.success(baseResponse.data))
            } catch {
                print("❌ 챗봇 디코딩 실패: \(error)")
                completion(.failure(error))
            }
        case .failure(let error):
            print("❌ 챗봇 네트워크 에러: \(error)")
            completion(.failure(error))
        }
    }
}
