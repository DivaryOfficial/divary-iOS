//
//  AttributedTextView.swift
//  Divary
//
//  Created by 바견규 on 7/23/25.
//

import SwiftUI
import UIKit

struct AttributedTextView: UIViewRepresentable {
    var attributedText: NSAttributedString

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText
    }
}
