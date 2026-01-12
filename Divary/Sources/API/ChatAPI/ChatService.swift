import Foundation
import Moya

final class ChatService {
    private let provider = MoyaProvider<ChatAPI>()
    
    func sendMessage(chatRoomId: Int?, message: String, imageData: Data?, completion: @escaping (Result<SendMessageResponseDTO, Error>) -> Void) {
        provider.requestWithAutoRefresh(
            makeTarget: { .sendMessage(chatRoomId: chatRoomId, message: message, imageData: imageData) }
        ) { result in
            self.handleSendMessageResponse(result, completion: completion)
        }
    }
    
    func getChatRooms(completion: @escaping (Result<ChatRoomListResponseDTO, Error>) -> Void) {
        provider.requestWithAutoRefresh(
            makeTarget: { .getChatRooms }
        ) { result in
            self.handleChatRoomsResponse(result, completion: completion)
        }
    }
    
    func getChatRoomDetail(chatRoomId: Int, completion: @escaping (Result<ChatRoomDetailResponseDTO, Error>) -> Void) {
        provider.requestWithAutoRefresh(
            makeTarget: { .getChatRoomDetail(chatRoomId: chatRoomId) }
        ) { result in
            self.handleChatRoomDetailResponse(result, completion: completion)
        }
    }
    
    func deleteChatRoom(chatRoomId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.requestWithAutoRefresh(
            makeTarget: { .deleteChatRoom(chatRoomId: chatRoomId) }
        ) { result in
            switch result {
            case .success:             completion(.success(()))
            case .failure(let error):  completion(.failure(error))
            }
        }
    }
    
    func updateChatRoomTitle(chatRoomId: Int, title: String, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.requestWithAutoRefresh(
            makeTarget: { .updateChatRoomTitle(chatRoomId: chatRoomId, title: title) }
        ) { result in
            switch result {
            case .success:             completion(.success(()))
            case .failure(let error):  completion(.failure(error))
            }
        }
    }
    
    // 이하 응답 핸들러는 원본 유지
    private func handleSendMessageResponse(_ result: Result<Response, MoyaError>, completion: @escaping (Result<SendMessageResponseDTO, Error>) -> Void) {
        switch result {
        case .success(let response):
            if let jsonString = String(data: response.data, encoding: .utf8) {
                DebugLogger.log("챗봇 서버 응답: \(jsonString)")
            }
            if response.statusCode >= 400 {
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
                DebugLogger.error("챗봇 디코딩 실패: \(error)")
                completion(.failure(error))
            }
        case .failure(let error):
            DebugLogger.error("챗봇 네트워크 에러: \(error)")
            completion(.failure(error))
        }
    }
    
    private func handleChatRoomsResponse(_ result: Result<Response, MoyaError>, completion: @escaping (Result<ChatRoomListResponseDTO, Error>) -> Void) {
        switch result {
        case .success(let response):
            if let jsonString = String(data: response.data, encoding: .utf8) {
                DebugLogger.log("챗봇 서버 응답: \(jsonString)")
            }
            if response.statusCode >= 400 {
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
                DebugLogger.error("챗봇 디코딩 실패: \(error)")
                completion(.failure(error))
            }
        case .failure(let error):
            DebugLogger.error("챗봇 네트워크 에러: \(error)")
            completion(.failure(error))
        }
    }
    
    private func handleChatRoomDetailResponse(_ result: Result<Response, MoyaError>, completion: @escaping (Result<ChatRoomDetailResponseDTO, Error>) -> Void) {
        switch result {
        case .success(let response):
            if let jsonString = String(data: response.data, encoding: .utf8) {
                DebugLogger.log("챗봇 서버 응답: \(jsonString)")
            }
            if response.statusCode >= 400 {
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
                DebugLogger.error("챗봇 디코딩 실패: \(error)")
                completion(.failure(error))
            }
        case .failure(let error):
            DebugLogger.error("챗봇 네트워크 에러: \(error)")
            completion(.failure(error))
        }
    }
}
