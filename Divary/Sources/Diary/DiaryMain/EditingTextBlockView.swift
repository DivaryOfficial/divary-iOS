//  EditingTextBlockView.swift
//  Divary
//  Created by 김나영 on 7/6/25.

import SwiftUI
import RichTextKit

struct EditingTextBlockView: View {
    @Bindable var viewModel: DiaryMainViewModel
    @FocusState.Binding var isRichTextEditorFocused: Bool
    let content: RichTextContent
    let shouldAutoFocus: Bool
    
    // 한글 입력 상태 추적
    @State private var isInternalUpdate: Bool = false
    @State private var lastTextLength: Int = 0
    @State private var lastCursorPosition: Int = 0
    
    @State private var cursorTimer: Timer?
    
    // 텍스트 높이 추적 - 단순화
    @State private var previousTextHeight: CGFloat = 0
    @State private var heightCheckTimer: Timer?
    
    // 포커스 안정화를 위한 상태
    @State private var isInitialSetupComplete: Bool = false
    @State private var focusDelayTimer: Timer?
    
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
                if shouldAutoFocus {
                    $isRichTextEditorFocused.wrappedValue = true
                }
                viewModel.currentTextAlignment = viewModel.getCurrentTextAlignment()
                
                // 새 텍스트 블록용 초기 설정
                setupInitialTypingAttributes()
            }
            await setupInitialState()
        }
        .onChange(of: isRichTextEditorFocused) { _, newValue in
            handleFocusChange(newValue)
        }
        .onChange(of: viewModel.forceUIUpdate) { _, _ in
            DispatchQueue.main.async {
                self.setupTypingAttributes()
            }
        }
        .onChange(of: viewModel.richTextContext.attributedString) { _, _ in
            // 텍스트 변화 시 높이 체크 예약
            scheduleHeightCheck()
        }
        .onChange(of: shouldAutoFocus) { _, newValue in
            // shouldAutoFocus가 변경되면 포커스 상태 조정
            if !newValue && isRichTextEditorFocused {
                // 자동 포커스가 비활성화되고 현재 포커스되어 있으면 포커스 해제
                DispatchQueue.main.async {
                    self.isRichTextEditorFocused = false
                }
            } else if newValue && !isRichTextEditorFocused && isInitialSetupComplete {
                // 자동 포커스가 활성화되고 현재 포커스되어 있지 않으면 포커스 설정
                DispatchQueue.main.async {
                    self.isRichTextEditorFocused = true
                }
            }
        }
    }
    
    // MARK: - 초기 설정
    
    @MainActor
    private func setupInitialState() async {
        setupTextViewAppearance()
        viewModel.richTextContext.setAttributedString(to: content.text)
        
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1초
        
        isInternalUpdate = false
        viewModel.currentTextAlignment = viewModel.getCurrentTextAlignment()
        
        setupInitialTypingAttributes()
        
        // 초기 높이 저장
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.previousTextHeight = self.getCurrentTextHeight()
            self.isInitialSetupComplete = true
        }
        
        // 포커스를 지연시켜 안정성 확보
        if shouldAutoFocus {
            delayedFocusSetup()
        }
    }
    
    // MARK: - 포커스 처리 개선
    
    private func delayedFocusSetup() {
        guard shouldAutoFocus else { return }
        
        focusDelayTimer?.invalidate()
        focusDelayTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            DispatchQueue.main.async {
                if self.isInitialSetupComplete && self.shouldAutoFocus {
                    self.isRichTextEditorFocused = true
                }
            }
        }
    }
    
    private func handleFocusChange(_ isFocused: Bool) {
        // 초기 설정이 완료되지 않았으면 포커스 변화 무시
        guard isInitialSetupComplete else { return }
        
        if isFocused {
            DispatchQueue.main.async {
                self.setupInitialTypingAttributes()
                self.startCursorMonitoring()
            }
        } else {
            DispatchQueue.main.async {
                self.viewModel.saveCurrentEditingBlock()
                self.stopCursorMonitoring()
                self.stopHeightCheck()
                self.cleanupTimers()
            }
        }
    }
    
    // MARK: - 텍스트 높이 모니터링 - 단순화
    
    private func scheduleHeightCheck() {
        // 초기 설정이 완료되지 않았으면 높이 체크 생략
        guard isInitialSetupComplete else { return }
        
        heightCheckTimer?.invalidate()
        heightCheckTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
            self.checkTextHeightAndScroll()
        }
    }
    
    private func checkTextHeightAndScroll() {
        let currentHeight = getCurrentTextHeight()
        
        // 높이가 한 줄 이상 증가했을 때만 스크롤 요청
        if currentHeight > previousTextHeight + 40 {
            requestScrollToCurrentBlock()
            previousTextHeight = currentHeight
        }
    }
    
    private func getCurrentTextHeight() -> CGFloat {
        guard let textView = findTextView() else { return 0 }
        return textView.contentSize.height
    }
    
    private func requestScrollToCurrentBlock() {
        guard let editingBlock = viewModel.editingTextBlock else { return }
        
        // 키보드 상태 확인을 위한 간단한 체크
        let isKeyboardShowing = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .contains { $0.isKeyWindow && $0.frame.height != UIScreen.main.bounds.height }

        // 키보드가 표시 중이면 스크롤 요청을 지연
        let scrollDelay = isKeyboardShowing ? 0.2 : 0.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + scrollDelay) {
            NotificationCenter.default.post(
                name: NSNotification.Name("ScrollToBlock"),
                object: editingBlock.id
            )
        }
    }
    
    private func stopHeightCheck() {
        heightCheckTimer?.invalidate()
        heightCheckTimer = nil
    }
    
    // MARK: - Text Handling
    
    private func handleTextUpdate(_ newValue: NSAttributedString) {
        let currentText = viewModel.richTextContext.attributedString
        let newLength = newValue.length
        let oldLength = currentText.length
        let lengthDifference = newLength - oldLength
        
        if lengthDifference >= 0 {
            handleTextInput(newValue, currentText: currentText)
        } else {
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
        
        if selectedRange.length > 0 {
            DispatchQueue.main.async {
                self.viewModel.richTextContext.setAttributedString(to: newValue)
            }
            return
        }
        
        let mutableNewValue = newValue.mutableCopy() as! NSMutableAttributedString
        
        if newValue.length > currentText.length {
            let newTextRange = NSRange(location: currentText.length, length: newValue.length - currentText.length)
            applyCurrentStyleToRange(mutableNewValue, range: newTextRange)
        } else if newValue.length == currentText.length {
            let cursorPosition = selectedRange.location
            if cursorPosition > 0 {
                let targetRange = NSRange(location: cursorPosition - 1, length: 1)
                if targetRange.location + targetRange.length <= mutableNewValue.length {
                    applyCurrentStyleToRange(mutableNewValue, range: targetRange)
                }
            }
        }
        
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
        
        if let font = UIFont(name: viewModel.currentFontName, size: viewModel.currentFontSize) {
            attributes[.font] = font
        } else {
            attributes[.font] = UIFont.systemFont(ofSize: viewModel.currentFontSize)
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = viewModel.currentTextAlignment
        attributes[.paragraphStyle] = paragraphStyle
        
        if viewModel.currentIsUnderlined {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        
        if viewModel.currentIsStrikethrough {
            attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
        }
        
        attributes[.foregroundColor] = UIColor.label
        
        mutableString.setAttributes(attributes, range: range)
    }
    
    // MARK: - Typing Attributes
    
    private func setupInitialTypingAttributes() {
        guard isInitialSetupComplete else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.setupTypingAttributes()
        }
    }
    
    private func setupTypingAttributes() {
        guard let textView = findTextView() else { return }
        
        let selectedRange = textView.selectedRange
        if selectedRange.length > 0 { return }
        
        var typingAttributes: [NSAttributedString.Key: Any] = [:]
        
        if let font = UIFont(name: viewModel.currentFontName, size: viewModel.currentFontSize) {
            typingAttributes[.font] = font
        } else {
            typingAttributes[.font] = UIFont.systemFont(ofSize: viewModel.currentFontSize)
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = viewModel.currentTextAlignment
        typingAttributes[.paragraphStyle] = paragraphStyle
        
        if viewModel.currentIsUnderlined {
            typingAttributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        
        if viewModel.currentIsStrikethrough {
            typingAttributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
        }
        
        typingAttributes[.foregroundColor] = UIColor.label
        
        textView.typingAttributes = typingAttributes
        
        for delay in [0.01, 0.03, 0.06] {
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
        cursorTimer?.invalidate()
        cursorTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            guard isRichTextEditorFocused && isInitialSetupComplete else {
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
        cursorTimer?.invalidate()
        cursorTimer = nil
    }
    
    // MARK: - 정리
    
    private func cleanupTimers() {
        focusDelayTimer?.invalidate()
        focusDelayTimer = nil
        cursorTimer?.invalidate()
        cursorTimer = nil
        heightCheckTimer?.invalidate()
        heightCheckTimer = nil
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
