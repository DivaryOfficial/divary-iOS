import SwiftUI

struct ChatInputBar: View {
    @Binding var messageText: String
    @Binding var showPhotoOptions: Bool
    @Binding var selectedImage: UIImage?
    let onSendMessage: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 선택된 이미지 미리보기
            if let selectedImage = selectedImage {
                HStack {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(8)
                        
                        Button(action: {
                            self.selectedImage = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                                .background(Color.gray)
                                .clipShape(Circle())
                                .font(.system(size: 16))
                        }
                        .offset(x: 5, y: -5)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    showPhotoOptions.toggle()
                }) {
                    Image(systemName: showPhotoOptions ? "xmark" : "plus")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.primary)
                }
                
                TextField("무엇이든 물어보세요", text: $messageText, axis: .vertical)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.grayscale_g100)
                    .foregroundStyle(Color.bw_black)
                    .cornerRadius(8)
                    .lineLimit(1...4)
                
                Button(action: {
                    onSendMessage()
                }) {
                    Image("Chatsend")
                        .frame(width: 24, height: 24)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedImage == nil)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            
            if showPhotoOptions {
                HStack {
                    PhotoSelectionView(selectedImage: $selectedImage)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    ChatInputBar(
        messageText: .constant(""),
        showPhotoOptions: .constant(false),
        selectedImage: .constant(nil),
        onSendMessage: {
            print("메시지 전송")
        }
    )
}
