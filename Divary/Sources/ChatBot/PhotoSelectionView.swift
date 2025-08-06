import SwiftUI

struct PhotoSelectionView: View {
    var body: some View {
        
        HStack(spacing: 40) {
            Button(action: {
                print("앨범 버튼 클릭")
                // 포토피커 로직
            }) {
                VStack(spacing: 8) {
                    Image("ChatPhoto")
                            .font(.system(size: 24))
                            .foregroundColor(.primary)
                
                    Text("앨범")
                        .font(.system(size: 10))
                        .foregroundColor(Color.bw_black)
                }
            }
            
            Button(action: {
                print("카메라 버튼 클릭")
                // 카메라 로직
            }) {
                VStack(spacing: 8) {
                    
                   Image("ChatCamera")
                            .font(.system(size: 24))
                            .foregroundColor(.primary)
                
                    
                    Text("카메라")
                        .font(.system(size: 10))
                        .foregroundColor(Color.bw_black)
                }
            }
        }
        
    }
}

#Preview {
    PhotoSelectionView()
}
