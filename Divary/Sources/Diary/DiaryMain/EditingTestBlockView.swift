//  EditingTextBlockView.swift
//  Divary
//  Created by 김나영 on 7/6/25.

import SwiftUI
import RichTextKit

struct EditingTextBlockView: View {
    @Bindable var viewModel: DiaryMainViewModel
    @FocusState.Binding var isRichTextEditorFocused: Bool
    let content: RichTextContent
    
    var body: some View {
        RichTextEditor(
            text: Binding(
                get: {
                    viewModel.richTextContext.attributedString
                },
                set: { newValue in
                    // 첫 번째 입력 시 typingAttributes 적용
                    let processedText = ensureCurrentFontSettings(newValue)
                    viewModel.richTextContext.setAttributedString(to: processedText)
                }
            ),
            context: viewModel.richTextContext
        )
        .focusedValue(\.richTextContext, viewModel.richTextContext)
        .focused($isRichTextEditorFocused)
        .frame(minHeight: 80)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.clear)
        .task {
            setupTextViewAppearance()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                $isRichTextEditorFocused.wrappedValue = true
                viewModel.currentTextAlignment = viewModel.getCurrentTextAlignment()
                
                // 새로 생성된 텍스트 블록의 경우 typing attributes 설정
                setupTypingAttributesForNewText()
            }
        }
        .onChange(of: isRichTextEditorFocused) { _, newValue in
            if newValue {
                // 포커스를 받을 때마다 typing attributes 설정
                setupTypingAttributesForNewText()
            } else {
                // 포커스가 해제될 때만 저장
                viewModel.saveCurrentEditingBlock()
            }
        }
        .onChange(of: viewModel.currentTextAlignment) { _, newAlignment in
            applyTextAlignment(newAlignment)
            // 정렬 변경 시에도 typing attributes 업데이트
            setupTypingAttributesForNewText()
        }
        .onChange(of: viewModel.getCurrentFontName()) { _, _ in
            // 폰트 변경 시 typing attributes 업데이트 및 저장
            setupTypingAttributesForNewText()
            viewModel.saveCurrentEditingBlock()
        }
        .onChange(of: viewModel.getCurrentFontSize()) { _, _ in
            // 폰트 크기 변경 시 typing attributes 업데이트 및 저장
            setupTypingAttributesForNewText()
            viewModel.saveCurrentEditingBlock()
        }
        .onChange(of: viewModel.forceUIUpdate) { _, _ in
            // forceUIUpdate 감지로 typing attributes 재설정
            setupTypingAttributesForNewText()
        }
    }
    
    private func setupTextViewAppearance() {
        UITextView.appearance().backgroundColor = UIColor.clear
        UITextView.appearance().textContainer.lineFragmentPadding = 0
        UITextView.appearance().textContainerInset = UIEdgeInsets.zero
    }
    
    private func setupTypingAttributesForNewText() {
        DispatchQueue.main.async {
            self.setTypingAttributes()
        }
    }
    
    private func setTypingAttributes() {
        // 현재 폰트 설정으로 typing attributes 생성
        var typingAttributes: [NSAttributedString.Key: Any] = [:]
        
        if let font = UIFont(name: viewModel.currentFontName, size: viewModel.currentFontSize) {
            typingAttributes[.font] = font
        } else {
            typingAttributes[.font] = UIFont.systemFont(ofSize: viewModel.currentFontSize)
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = viewModel.currentTextAlignment
        typingAttributes[.paragraphStyle] = paragraphStyle
        
        // UITextView에 직접 설정
        if let textView = findTextView() {
            textView.typingAttributes = typingAttributes
        }
        
        // RichTextContext의 fontSize도 동기화
        viewModel.richTextContext.fontSize = viewModel.currentFontSize
    }
    
    private func findTextView() -> UITextView? {
        // SwiftUI 계층에서 현재 포커스된 UITextView를 찾는 헬퍼 메서드
        let scenes = UIApplication.shared.connectedScenes
        for scene in scenes {
            if let windowScene = scene as? UIWindowScene {
                for window in windowScene.windows {
                    if let textView = findTextViewInView(window) {
                        return textView
                    }
                }
            }
        }
        return nil
    }
    
    private func findTextViewInView(_ view: UIView) -> UITextView? {
        if let textView = view as? UITextView, textView.isFirstResponder {
            return textView
        }
        
        for subview in view.subviews {
            if let textView = findTextViewInView(subview) {
                return textView
            }
        }
        
        return nil
    }
    
    private func ensureCurrentFontSettings(_ attributedString: NSAttributedString) -> NSAttributedString {
        let mutableString = attributedString.mutableCopy() as! NSMutableAttributedString
        
        guard mutableString.length > 0 else {
            return attributedString
        }
        
        // 현재 설정된 폰트 생성
        let currentFont: UIFont
        if let font = UIFont(name: viewModel.currentFontName, size: viewModel.currentFontSize) {
            currentFont = font
        } else {
            currentFont = UIFont.systemFont(ofSize: viewModel.currentFontSize)
        }
        
        // 전체 텍스트에 현재 폰트 설정 강제 적용
        let fullRange = NSRange(location: 0, length: mutableString.length)
        mutableString.addAttribute(.font, value: currentFont, range: fullRange)
        
        // 정렬도 강제 적용
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = viewModel.currentTextAlignment
        mutableString.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
        
        return mutableString
    }
    
    private func applyTextAlignment(_ alignment: NSTextAlignment) {
        let currentText = viewModel.richTextContext.attributedString
        let mutableString = currentText.mutableCopy() as! NSMutableAttributedString
        
        guard mutableString.length > 0 else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        
        // 기존 스타일 보존
        if let existingStyle = mutableString.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle {
            paragraphStyle.lineSpacing = existingStyle.lineSpacing
            paragraphStyle.paragraphSpacing = existingStyle.paragraphSpacing
        }
        
        let fullRange = NSRange(location: 0, length: mutableString.length)
        mutableString.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
        
        viewModel.richTextContext.setAttributedString(to: mutableString)
    }
}
