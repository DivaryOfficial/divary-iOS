//
//  example.swift
//  Divary
//
//  Created by 바견규 on 7/22/25.
//

import SwiftUI
import RichTextKit
import PhotosUI

struct EditorView: View {
    @State private var text = NSAttributedString(string: "")
    @StateObject private var context = RichTextContext()
    @State private var showImagePicker = false
    @State private var inputImage: UIImage?

    var body: some View {
        VStack(spacing: 0) {
            RichTextEditor(text: $text, context: context)
                .focusedValue(\.richTextContext, context)
                .frame(minHeight: 300)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2))
                )

            customToolbar
        }
        .sheet(isPresented: $showImagePicker) {
            PhotoPicker(image: $inputImage)
        }
    }
    
    private var customToolbar: some View {
        HStack(spacing: 16) {
            Button(action: { context.toggleStyle(.bold) }) {
                Image(systemName: "bold")
            }

            Button(action: { context.toggleStyle(.italic) }) {
                Image(systemName: "italic")
            }

            Button(action: { context.toggleStyle(.underlined) }) {
                Image(systemName: "underline")
            }

            Button(action: { context.toggleStyle(.strikethrough) }) {
                Image(systemName: "strikethrough")
            }

            Button(action: { showImagePicker = true }) {
                Image(systemName: "photo")
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
    }
}


struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else {
                return
            }

            provider.loadObject(ofClass: UIImage.self) { object, error in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self.parent.image = image
                    }
                }
            }
        }
    }
}

#Preview {
    EditorView()
}









