//
//  AttributedTextView.swift
//  Divary
//
//  Created by 바견규 on 7/23/25.
//

import SwiftUI
import UIKit

final class IntrinsicTextView: UITextView {
    override var intrinsicContentSize: CGSize {
        // 폭이 0일 때는 기본값을 내보내면 잘못된 높이가 나올 수 있음
        // bounds.width가 잡힌 뒤엔 해당 폭 기준으로 세로 길이를 계산
        if bounds.width > 0 {
            let fit = sizeThatFits(CGSize(width: bounds.width,
                                          height: .greatestFiniteMagnitude))
            return CGSize(width: UIView.noIntrinsicMetric, height: fit.height)
        } else {
            return super.intrinsicContentSize
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 폭이 변하면(예: 회전, 부모 레이아웃 변경) 다시 재측정
        invalidateIntrinsicContentSize()
    }
}

struct CustomAttributedTextView: UIViewRepresentable {
    let attributedText: NSAttributedString

    func makeUIView(context: Context) -> IntrinsicTextView {
        let tv = IntrinsicTextView()
        tv.backgroundColor = .clear
        tv.isEditable = false
        tv.isSelectable = false
        tv.isScrollEnabled = false

        tv.textContainer.lineFragmentPadding = 0
        tv.textContainerInset = .zero
        tv.textContainer.widthTracksTextView = true

        tv.setContentHuggingPriority(.defaultHigh, for: .vertical)
        tv.setContentCompressionResistancePriority(.required, for: .vertical)
        tv.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return tv
    }

    func updateUIView(_ uiView: IntrinsicTextView, context: Context) {
        // 텍스트 바뀌면 즉시 레이아웃 재측정 트리거
        uiView.attributedText = attributedText
        uiView.setNeedsLayout()
        uiView.layoutIfNeeded()
        uiView.invalidateIntrinsicContentSize()
    }
}
