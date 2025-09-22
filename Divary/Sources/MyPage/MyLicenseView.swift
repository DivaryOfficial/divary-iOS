//
//  MyLicenseView.swift
//  Divary
//
//  Created by 김나영 on 9/22/25.
//

import SwiftUI
import PhotosUI

struct MyLicenseView: View {
    @Environment(\.diContainer) private var di
    
    var onTapBell: () -> Void = {}
    
    // UI 상태
    @State private var showSourceMenu = false
    @State private var showPhotosPicker = false
    @State private var showCameraPicker = false
    
    // 결과 (후속 업로드/미리보기 연결용)
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 0) {
            TopBar(isMainView: false, title: "나의 라이센스", onBell: onTapBell)
            
            LicenseCard(
                showSourceMenu: $showSourceMenu,
                onTapRegister: { showSourceMenu.toggle() },
                onTapAlbum: { showPhotosPicker = true },
                onTapCamera: { showCameraPicker = true }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .inset(by: 0.5)
                    .stroke(Color(red: 0.8, green: 0.8, blue: 0.8), lineWidth: 1)
            )
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
            
            Spacer()
        }
        
        // 앨범
        .photosPicker(isPresented: $showPhotosPicker,
                      selection: $selectedItem,
                      matching: .images)
        .onChange(of: selectedItem) { _, newValue in
            guard let item = newValue else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                    // TODO: 여기서 업로드/미리보기 화면으로 라우팅하거나 상태 업데이트
                    // di.router.push(.licensePreview(image: image)) 등
                }
            }
        }
        
        // 카메라
        .sheet(isPresented: $showCameraPicker) {
            CameraPicker(image: $selectedImage)
                .ignoresSafeArea()
        }
    }
}

// MARK: - 카드 컴포넌트

private struct LicenseCard: View {
    @Binding var showSourceMenu: Bool
    var onTapRegister: () -> Void
    var onTapAlbum: () -> Void
    var onTapCamera: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Group {
                if showSourceMenu {
                    HStack(spacing: 40) {
                        SourceButton(iconName: "album", action: onTapAlbum)
                        SourceButton(iconName: "camera", action: onTapCamera)
                    }
                } else {
                    Button(action: onTapRegister) {
                        Image(systemName: "plus")
                            .font(.system(size: 35, weight: .regular))
                            .foregroundStyle(Color(.grayscaleG400))
                    }
                }
            }
            .frame(height: 160)
            
            Button(action: onTapRegister) {
                Text(showSourceMenu ? "취소" : "라이센스 이미지 등록하기")
                    .font(.omyu.regular(size: 20))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.primarySeaBlue))
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(12)
    }
}

private struct SourceButton: View {
    let iconName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(iconName)
                .font(.system(size: 24, weight: .semibold))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 카메라 피커 래퍼

private struct CameraPicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    @Binding var image: UIImage?
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary // 시뮬레이터 대체
        }
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    MyLicenseView()
}
