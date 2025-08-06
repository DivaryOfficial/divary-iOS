import SwiftUI

struct MessageBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    
                    if let imageData = message.image {
                        // 이미지 들어감
                        Rectangle()
                            .fill(Color.grayscale_g100)
                            .frame(width: 94, height: 94)
                            .overlay(
                                Group {
                                    if let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                    } else {
                                        Image("seaBack")
                                            .resizable()
                                            .scaledToFill()
                                    }
                                }
                            )
                            .clipped()
                            .cornerRadius(12)
                    }
                    
                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.secondary_pb100)
                        .foregroundColor(Color.bw_black)
                        .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 14))
                        .roundingCorner(16, corners: [.topLeft, .topRight, .bottomLeft])
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
                
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.grayscale_g100)
                        .foregroundColor(Color.bw_black)
                        .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 14))
                        .roundingCorner(16, corners: [.topLeft, .topRight, .bottomRight])
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                
                Spacer()
            }
        }
    }
}

#Preview {
    VStack(spacing: 10) {
        MessageBubbleView(message: ChatMessage(content: "안녕하세요!", isUser: false))
        MessageBubbleView(message: ChatMessage(content: "네, 안녕하세요!", isUser: true))
        MessageBubbleView(message: ChatMessage(content: "사진 보내드려요", isUser: true, image: Data()))
    }
    .padding()
}

