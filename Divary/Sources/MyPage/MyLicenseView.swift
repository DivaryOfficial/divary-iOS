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
    @State private var showFullScreen = false

    // 결과 (1장만)
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 0) {
            TopBar(isMainView: false, title: "나의 라이센스", onBell: onTapBell)
            
            LicenseCard(
                selectedImage: $selectedImage,
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
            
            // ▶ 등록된 뒤 + 소스 메뉴가 닫혀 있을 때만 두 버튼 노출
            if selectedImage != nil && !showSourceMenu {
                HStack(spacing: 16) {
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showSourceMenu = true   // 다시 등록하기 → 메뉴 열기(이미지는 유지)
                        }
                    } label: {
                        Text("다시 등록하기")
                            .font(.omyu.regular(size: 20))
                            .foregroundStyle(Color(.grayscaleG500))
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.grayscaleG200))
                            )
                    }
                    .buttonStyle(.plain)

                    Button {
                        showFullScreen = true      // 크게 보기
                    } label: {
                        Text("크게 보기")
                            .font(.omyu.regular(size: 20))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.primarySeaBlue))
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            
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
                    // 선택되면 메뉴 닫고 등록 상태로 전환
                    withAnimation(.easeOut(duration: 0.2)) { showSourceMenu = false }
                }
            }
        }
        
        // 카메라
        .sheet(isPresented: $showCameraPicker) {
            CameraPicker(image: $selectedImage)
                .onDisappear {
                    // 촬영 후 바로 등록 상태로
                    if selectedImage != nil {
                        withAnimation(.easeOut(duration: 0.2)) { showSourceMenu = false }
                    }
                }
                .ignoresSafeArea()
        }

        // 크게 보기 (풀스크린)
        .fullScreenCover(isPresented: $showFullScreen) {
            if let img = selectedImage {
                LicenseFullScreenView(image: img)
            }
        }
    }
}

private struct LicenseCard: View {
    @Binding var selectedImage: UIImage?
    @Binding var showSourceMenu: Bool
    var onTapRegister: () -> Void
    var onTapAlbum: () -> Void
    var onTapCamera: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Group {
                if showSourceMenu {
                    HStack(spacing: 48) {
                        SourceButton(iconName: "album", action: onTapAlbum)
                        SourceButton(iconName: "camera", action: onTapCamera)
                    }
                } else if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding(12)
//                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                } else {
                    Button(action: onTapRegister) {
                        Image(systemName: "plus")
                            .font(.system(size: 35, weight: .regular))
                            .foregroundStyle(Color(.grayscaleG400))
                    }
                }
            }
            .frame(height: 160)
            
            // ▶ 등록 전이거나, 메뉴가 열려 있을 때만 노출 (취소/등록하기 버튼)
            if selectedImage == nil || showSourceMenu {
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
// MARK: - 풀스크린 뷰어
private struct LicenseFullScreenView: View {
    @Environment(\.dismiss) private var dismiss
    let image: UIImage

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .padding()
                .background(Color.black)

            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    Spacer()
                }
                .padding(.top, 8)
                .padding(.leading, 8)
                Spacer()
            }
        }
    }
}

#Preview {
    MyLicenseView()
}
