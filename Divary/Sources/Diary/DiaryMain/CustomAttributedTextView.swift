//
//  AttributedTextView.swift
//  Divary
//
//  Created by 바견규 on 7/23/25.
//

import SwiftUI
import UIKit

struct CustomAttributedTextView: UIViewRepresentable {
    let attributedText: NSAttributedString
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = UIColor.clear
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets.zero
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // AttributedString의 정렬을 포함한 모든 속성을 그대로 적용
        uiView.attributedText = attributedText
        
        // 텍스트 변경 후 크기 재계산
        DispatchQueue.main.async {
            uiView.invalidateIntrinsicContentSize()
        }
    }
}
