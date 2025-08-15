import Foundation
import Moya

enum ChatAPI {
    case sendMessage(chatRoomId: Int?, message: String, image: String?)
    case getChatRooms
    case getChatRoomDetail(chatRoomId: Int)
    case deleteChatRoom(chatRoomId: Int)
    case updateChatRoomTitle(chatRoomId: Int, title: String)
}

extension ChatAPI: TargetType {
    var baseURL: URL {
        guard let baseUrlString = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String,
              let url = URL(string: baseUrlString) else {
            fatalError("⚠️ API_URL not found or invalid in Info.plist")
        }
        return url
    }

    var path: String {
        switch self {
        case .sendMessage, .getChatRooms:
            return "/api/v1/chatrooms"
        case .getChatRoomDetail(let chatRoomId), .deleteChatRoom(let chatRoomId):
            return "/api/v1/chatrooms/\(chatRoomId)"
        case .updateChatRoomTitle(let chatRoomId, _):
            return "/api/v1/chatrooms/\(chatRoomId)/title"
        }
    }

    var method: Moya.Method {
        switch self {
        case .sendMessage:
            return .post
        case .getChatRooms, .getChatRoomDetail:
            return .get
        case .deleteChatRoom:
            return .delete
        case .updateChatRoomTitle:
            return .patch
        }
    }

    var task: Task {
        switch self {
        case .sendMessage(let chatRoomId, let message, let imageUrl):
            var formData: [MultipartFormData] = []
            
            print("🔍 ChatAPI - 전송 파라미터:")
            print("  - chatRoomId: \(chatRoomId?.description ?? "nil")")
            print("  - message: \(message)")
            print("  - imageUrl: \(imageUrl ?? "nil")")
            
            // message는 필수
            formData.append(MultipartFormData(provider: .data(message.data(using: .utf8)!), name: "message"))
            
            // chatRoomId는 선택적 (새 채팅방 생성시에는 nil)
            if let chatRoomId = chatRoomId {
                formData.append(MultipartFormData(provider: .data("\(chatRoomId)".data(using: .utf8)!), name: "chatRoomId"))
            }
            
            // 🔍 이미지 URL이 있을 때만 추가 (빈 값이면 아예 안 보냄)
            if let imageUrl = imageUrl, !imageUrl.isEmpty {
                print("  - 이미지 URL 추가: \(imageUrl)")
                formData.append(MultipartFormData(
                    provider: .data(imageUrl.data(using: .utf8)!),
                    name: "image"
                ))
            } else {
                print("  - 이미지 없음: image 필드 제외")
            }
            
            print("  - FormData 항목 수: \(formData.count)")
            
            return .uploadMultipart(formData)
            
        case .getChatRooms, .getChatRoomDetail, .deleteChatRoom:
            return .requestPlain
        case .updateChatRoomTitle(_, let title):
            let params: [String: Any] = ["title": title]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }

    var headers: [String : String]? {
        var headers: [String: String] = [
            "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
            "accept": "application/json"
        ]
        
        // multipart/form-data일 때는 Content-Type을 설정하지 않음 (Moya가 자동으로 처리)
        switch self {
        case .sendMessage:
            break // Content-Type은 Moya가 자동으로 설정
        default:
            headers["Content-Type"] = "application/json"
        }
        
        if let accessToken = KeyChainManager.shared.readAccessToken() {
            headers["Authorization"] = "Bearer \(accessToken)"
            print("🔍 Authorization 헤더 설정됨")
        } else {
            print("⚠️ accessToken 없음: 인증이 필요한 요청입니다.")
        }
        
        return headers
    }

    var sampleData: Data {
        return Data()
    }
}
