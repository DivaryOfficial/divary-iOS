//  EditingTextBlockView.swift
//  Divary
//  Created by 김나영 on 7/6/25.

import SwiftUI
import RichTextKit



struct EditingTextBlockView: View {
    @Bindable var viewModel: DiaryMainViewModel
    @FocusState.Binding var isRichTextEditorFocused: Bool
    let content: RichTextContent
    
    // 한글 입력 상태 추적
    @State private var isInternalUpdate: Bool = false // true?
    @State private var lastTextLength: Int = 0
    @State private var lastCursorPosition: Int = 0
    
    @State private var cursorTimer: Timer?
    
    var body: some View {
        RichTextEditor(
            text: Binding(
                get: {
                    viewModel.richTextContext.attributedString
                },
                set: { newValue in
                    if !isInternalUpdate {
                        handleTextUpdate(newValue)
                    }
                }
            ),
            context: viewModel.richTextContext
        )
        .focusedValue(\.richTextContext, viewModel.richTextContext)
        .focused($isRichTextEditorFocused)
        .frame(minHeight: 80)
        .fixedSize(horizontal: false, vertical: true)
        .scrollDisabled(true)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.clear)
        .task {
            setupTextViewAppearance()
            viewModel.richTextContext.setAttributedString(to: content.text)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                isInternalUpdate = false
                $isRichTextEditorFocused.wrappedValue = true
                viewModel.currentTextAlignment = viewModel.getCurrentTextAlignment()
                
                // 새 텍스트 블록용 초기 설정
                setupInitialTypingAttributes()
            }
        }
        .onChange(of: isRichTextEditorFocused) { _, newValue in
            if newValue {
                // 편집 진입 시: UI 관련은 다음 틱
//                DispatchQueue.main.async {
                    setupInitialTypingAttributes()
                    startCursorMonitoring()
//                }
            } else {
                // 편집 종료 시: 모델 저장/정리도 다음 틱
//                DispatchQueue.main.async {
                    viewModel.saveCurrentEditingBlock()
                    stopCursorMonitoring()
//                }
            }
        }
        .onChange(of: viewModel.forceUIUpdate) { _, _ in
            // UI 강제 업데이트 시 typing attributes 재설정
            DispatchQueue.main.async {
                self.setupTypingAttributes()
            }
        }
    }
    
    // MARK: - Text Handling
    
    private func handleTextUpdate(_ newValue: NSAttributedString) {
        let currentText = viewModel.richTextContext.attributedString
        let newLength = newValue.length
        let oldLength = currentText.length
        let lengthDifference = newLength - oldLength
        
        // 삭제 작업 감지 (-> 이거 왜 사용 안하고있다고 경고뜸)
//        let isDeleteOperation = lengthDifference < 0
        
        if lengthDifference >= 0 {
            // 텍스트 추가 또는 한글 조합
            handleTextInput(newValue, currentText: currentText)
        } else {
            // 텍스트 삭제
            // 동기 변이 금지 → 다음 틱으로 미룸
            DispatchQueue.main.async {
                self.viewModel.richTextContext.setAttributedString(to: newValue)
                self.viewModel.handleTextChange(isDeleteOperation: true)
            }
        }
        
        lastTextLength = newLength
    }
    
    private func handleTextInput(_ newValue: NSAttributedString, currentText: NSAttributedString) {
        guard let textView = findTextView() else {
            DispatchQueue.main.async {
                self.viewModel.richTextContext.setAttributedString(to: newValue)
            }
            return
        }
        
        let selectedRange = textView.selectedRange
        
        // 선택된 텍스트가 있으면 기본 처리
        if selectedRange.length > 0 {
            DispatchQueue.main.async {
                self.viewModel.richTextContext.setAttributedString(to: newValue)
            }
            return
        }
        
        // 새로운 입력에 현재 스타일 적용
        let mutableNewValue = newValue.mutableCopy() as! NSMutableAttributedString
        
        if newValue.length > currentText.length {
            // 새 텍스트 추가
            let newTextRange = NSRange(location: currentText.length, length: newValue.length - currentText.length)
            applyCurrentStyleToRange(mutableNewValue, range: newTextRange)
        } else if newValue.length == currentText.length {
            // 한글 조합 중 (길이 동일)
            let cursorPosition = selectedRange.location
            if cursorPosition > 0 {
                let targetRange = NSRange(location: cursorPosition - 1, length: 1)
                if targetRange.location + targetRange.length <= mutableNewValue.length {
                    applyCurrentStyleToRange(mutableNewValue, range: targetRange)
                }
            }
        }
        
        // 업데이트 적용
        isInternalUpdate = true
        
        DispatchQueue.main.async {
            self.viewModel.richTextContext.setAttributedString(to: mutableNewValue)
            self.isInternalUpdate = false
            self.setupTypingAttributes()
        }
    }
    
    private func applyCurrentStyleToRange(_ mutableString: NSMutableAttributedString, range: NSRange) {
        guard range.location >= 0 && range.location + range.length <= mutableString.length else { return }
        
        var attributes: [NSAttributedString.Key: Any] = [:]
        
        // 폰트
        if let font = UIFont(name: viewModel.currentFontName, size: viewModel.currentFontSize) {
            attributes[.font] = font
        } else {
            attributes[.font] = UIFont.systemFont(ofSize: viewModel.currentFontSize)
        }
        
        // 정렬
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = viewModel.currentTextAlignment
        attributes[.paragraphStyle] = paragraphStyle
        
        // 밑줄
        if viewModel.currentIsUnderlined {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        
        // 취소선
        if viewModel.currentIsStrikethrough {
            attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
        }
        
        // 색상
        attributes[.foregroundColor] = UIColor.label
        
        mutableString.setAttributes(attributes, range: range)
    }
    
    // MARK: - Typing Attributes
    
    private func setupInitialTypingAttributes() {
        DispatchQueue.main.async {
            self.setupTypingAttributes()
        }
    }
    
    private func setupTypingAttributes() {
        guard let textView = findTextView() else { return }
        
        let selectedRange = textView.selectedRange
        if selectedRange.length > 0 { return }
        
        var typingAttributes: [NSAttributedString.Key: Any] = [:]
        
        // 폰트
        if let font = UIFont(name: viewModel.currentFontName, size: viewModel.currentFontSize) {
            typingAttributes[.font] = font
        } else {
            typingAttributes[.font] = UIFont.systemFont(ofSize: viewModel.currentFontSize)
        }
        
        // 정렬
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = viewModel.currentTextAlignment
        typingAttributes[.paragraphStyle] = paragraphStyle
        
        // 밑줄
        if viewModel.currentIsUnderlined {
            typingAttributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        
        // 취소선
        if viewModel.currentIsStrikethrough {
            typingAttributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
        }
        
        // 색상
        typingAttributes[.foregroundColor] = UIColor.label
        
        // 적용
        textView.typingAttributes = typingAttributes
        
        // 한글 IME 대응 재시도
        for delay in [0.01, 0.02, 0.05] {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if textView.selectedRange.length == 0 {
                    textView.typingAttributes = typingAttributes
                }
            }
        }
        
        viewModel.richTextContext.fontSize = viewModel.currentFontSize
    }
    
    // MARK: - Cursor Monitoring
    
    private func startCursorMonitoring() {
        // 커서 위치 변경 모니터링
        cursorTimer?.invalidate()
        cursorTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            guard isRichTextEditorFocused else {
                timer.invalidate()
                return
            }
            
            if let textView = findTextView() {
                let currentPosition = textView.selectedRange.location
                if currentPosition != lastCursorPosition && textView.selectedRange.length == 0 {
                    lastCursorPosition = currentPosition
                    DispatchQueue.main.async {
                        self.viewModel.handleCursorPositionChange()
                    }
                }
            }
        }
        RunLoop.main.add(cursorTimer!, forMode: .common)
    }
    
    private func stopCursorMonitoring() {
        // 타이머는 자동으로 해제됨 (isRichTextEditorFocused 체크로)
        cursorTimer?.invalidate()
        cursorTimer = nil
    }
    
    // MARK: - Setup
    
    private func setupTextViewAppearance() {
        UITextView.appearance().backgroundColor = UIColor.clear
        UITextView.appearance().textContainer.lineFragmentPadding = 0
        UITextView.appearance().textContainerInset = UIEdgeInsets.zero
    }
    
    // MARK: - Helper
    
    private func findTextView() -> UITextView? {
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
}
