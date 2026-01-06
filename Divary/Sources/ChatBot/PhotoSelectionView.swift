import SwiftUI
import PhotosUI

struct PhotoSelectionView: View {
    @Binding var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        HStack(spacing: 40) {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                VStack(spacing: 8) {
                    Image("ChatPhoto")
                        .font(.system(size: 24))
                        .foregroundStyle(.primary)
                
                    Text("앨범")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.bw_black)
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let newItem,
                       let data = try? await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            selectedImage = uiImage
                        }
                    }
                }
            }
            
//            Button(action: {
//                print("카메라 버튼 클릭")
//                // 카메라 로직은 나중에 구현
//            }) {
//                VStack(spacing: 8) {
//                    Image("ChatCamera")
//                        .font(.system(size: 24))
//                        .foregroundStyle(.primary)
//                    
//                    Text("카메라")
//                        .font(.system(size: 10))
//                        .foregroundStyle(Color.bw_black)
//                }
            }
        }
    }

#Preview {
    PhotoSelectionView(selectedImage: .constant(nil))
}
